#!/usr/bin/env python3
"""Generate source-pinned explanatory SVGs. These are diagrams, never native captures.

Only standard-library modules are required. Run with --check to verify deterministic
output without writing. Source hashes from the catalog fail closed when stale.
"""
import argparse
import hashlib
import html
import json
from pathlib import Path
import re
import sys
import textwrap
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'docs/assets/illustrations'
WIDTH, HEIGHT = 1200, 760
INK, MUTED, ACCENT, LINE = '#182c36', '#536771', '#176f76', '#ccd9df'
PROFILE = 'Sources/DesignOSApple/Profile/DesignOSProfile.swift'
STYLE = 'Sources/DesignOSApple/AppStyle/DesignOSAppStyle.swift'
SURFACE = 'Sources/DesignOSApple/Platform/PlatformSurface.swift'
TYPOGRAPHY = 'Sources/DesignOSApple/Platform/PlatformTypography.swift'
PALETTE = 'Sources/DesignOSApple/AppStyle/DesignOSAppPalette.swift'

# A fixed registry survives catalog integration: adding an illustration must not make
# its generator stop selecting that entry. Every value below is checked against the
# pinned source or a separately pinned supporting declaration before rendering.
SPECS = {
 'primitive/section-content-layout': ('section', ['HStack(spacing: 8)', 'alignment: .leading', 'AccessorySlotLayout'], [], {'gapPoints': 8, 'slots': ['title: flexible leading', 'trailing: AccessorySlotLayout']}),
 'primitive/accessory-slot-layout': ('accessory', ['spacing: CGFloat = 8', 'HStack(spacing: spacing)'], [], {'defaultSpacingPoints': 8, 'content': 'caller-owned ViewBuilder content'}),
 'primitive/symbol-content': ('symbols', ['case .regular: 52', 'case .tall: 68', 'case .regular: 42', 'case .tall: 60', 'case .regular: 30', 'case .tall: 44', 'case .regular: 7', 'case .tall: 11'], [], {'regular': {'fill':52,'circular':42,'rounded':30,'roundedRadius':7}, 'tall': {'fill':68,'circular':60,'rounded':44,'roundedRadius':11}, 'symbol':'content unchanged'}),
 'primitive/sidebar-toolbar-content': ('sidebar', ['HStack(spacing: 12)', 'Spacer(minLength: 8)', 'AccessorySlotLayout(spacing: 24)'], [], {'outerSpacingPoints':12,'minimumSpacerPoints':8,'accessorySpacingPoints':24}),
 'primitive/editorial-adaptive-row-layout': ('adaptiveRow', ['guard !accessibilitySize else { return true }', 'total > availableWidth', 'let flexibleIndex = min(1, idealWidths.count - 1)', 'anchor: .topLeading'], [], {'verticalWhen':['accessibility size','invalid width/ideal measurement','ideal widths plus gaps exceed available width'], 'horizontal':'label/accessory retain intrinsic widths; value receives remaining width', 'direction':'SwiftUI owns RTL placement'}),
 'primitive/editorial-geometry': ('geometry', ['value.isFinite && value > 0 ? value : 1', 'value.isFinite && value >= 0 ? value : 0', 'min(length(requested), min(length(size.width), length(size.height)) / 2)'], [], {'invalidAspectRatioFallback':1,'invalidLengthFallback':0,'diameter':'positive finite request, else positive finite fallback, else 1','cornerRadius':'min(validated requested radius, half shortest side)'}),
 'primitive/editorial-clipped-content': ('clip', ['DesignOSEditorialGeometry.length(size.width)', 'DesignOSEditorialGeometry.length(size.height)', '.clipped()', '.clipShape(shape)'], [], {'order':['finite width/height frame','clipped()','clipShape(shape)'],'content':'caller-owned View and Shape'}),
 'native/home-screen-quick-action-recipe': ('quickAction', ['UIApplicationShortcutItem','UIApplication.shortcutItems','UIWindowSceneDelegate','app owns routing and completion'], [], {'platform':'iOS / iPadOS app host','flow':['create localized UIApplicationShortcutItem values','set UIApplication.shortcutItems','handle initial connection options or UIWindowSceneDelegate callback'],'systemOwns':'Home Screen presentation and interaction'}),
 'native/system-device-chrome-host-recipe': ('deviceHost', ['WindowGroup','safeAreaInset','LAContext','UNUserNotificationCenter','system owns status'], [], {'host':['App / Scene / WindowGroup','safeAreaInset app content','LAContext authentication','UNUserNotificationCenter notifications'],'systemOwns':['bars and keyboards','prompts and notifications','lock/Home screens and dock','window controls and accessibility']}),
 'native/extension-control-widget': ('controlWidget', ['ControlWidget','StaticControlConfiguration','ControlWidgetButton','ControlWidgetToggle','App Intents','iOS 18.0'], [], {'minimumVersion':'iOS / iPadOS 18','host':['ControlWidget','StaticControlConfiguration','ControlWidgetButton or ControlWidgetToggle','App Intents'],'hostOwns':'lifecycle and intent state','systemOwns':'placement, bounds and interaction chrome'}),
 'native/extension-widget': ('widget', ['WidgetBundle','StaticConfiguration','timeline provider','iOS 17.0'], [], {'minimumVersion':'iOS / iPadOS 17','host':['Widget / WidgetBundle','StaticConfiguration','timeline provider and content'],'hostOwns':'lifecycle, families, data and intent state','systemOwns':'placement, bounds, margins and interaction chrome'}),
 'support/adaptive-color': ('adaptiveColor', ['lightRGB: UInt32','darkRGB: UInt32','increasedContrastLightRGB','increasedContrastDarkRGB','0xFF_FFFF','Alpha is intentionally unsupported'], [PALETTE], {'storage':'opaque 24-bit sRGB; no alpha','axes':['light/dark','standard/increased contrast'],'omittedHighContrast':'falls back to corresponding standard variant','example':'DesignOSAppPalette.defaultDangerInk'}),
 'support/app-metrics': ('metrics', ['actionMinHeight >= 44','mediaSize > 0','mediaRadius <= mediaSize / 2','actionRadius: CGFloat = 12'], [STYLE], {'validation':['finite and nonnegative','actionMinHeight >= 44','mediaSize > 0','mediaRadius <= mediaSize / 2'],'editorialPoints':{'pageInset':20,'sectionSpacing':24,'contentInset':16,'itemSpacing':12,'surfaceRadius':24,'actionMinHeight':54,'mediaSize':80,'mediaRadius':8},'legacyActionRadiusDefault':12}),
 'support/app-palette': ('palette', ['defaultDangerInk','outgoingMessage ?? DesignOSAppColorPair(background: surface, foreground: ink)','disabledAction ?? DesignOSAppColorPair(background: subtleSurface, foreground: secondaryInk)'], [STYLE], {'roles':['canvas','surface','subtleSurface','ink','secondaryInk','separator','action','actionInk','dangerInk'],'pairs':['outgoingMessage','disabledAction'],'sample':'exact editorial preset RGB values; not universal system colors'}),
 'support/app-style': ('style', ['public let profile: DesignOSProfile','public let palette: DesignOSAppPalette','public let metrics: DesignOSAppMetrics','.designOSProfile(style.profile)'], [], {'composition':['profile: DesignOSProfile','palette: DesignOSAppPalette','metrics: DesignOSAppMetrics'],'injection':'designOSAppStyle(style) also injects style.profile','ownership':'opt-in content only; native controls remain native'}),
 'support/platform-accessibility': ('preferences', ['reduceMotion: Bool','reduceTransparency: Bool','differentiateWithoutColor: Bool','case standard','case increased'], [], {'preferences':['reduceMotion: Bool','reduceTransparency: Bool','differentiateWithoutColor: Bool','contrast: standard | increased'],'purpose':'immutable input preferences; not a settings override'}),
 'support/platform-semantic-color': ('semanticMap', ['case .labelPrimary: .label','case .labelPrimary: .labelColor','case .backgroundPrimary: .systemBackground','case .backgroundPrimary: .windowBackgroundColor'], [], {'mappings':[{'role':'labelPrimary','iOS':'UIColor.label','macOS':'NSColor.labelColor'},{'role':'backgroundPrimary','iOS':'UIColor.systemBackground','macOS':'NSColor.windowBackgroundColor'},{'role':'separator','iOS':'UIColor.separator','macOS':'NSColor.separatorColor'}],'limit':'dynamic native color values are intentionally not replaced with fixed swatches'}),
 'support/platform-surface': ('surfacePolicy', ['preferences.reduceTransparency ? .content : .material','presentation == .material ? .content : presentation','profile.radius.customContent'], [], {'content':'backgroundSecondary','groupedContent':'groupedBackgroundSecondary','translucentContent':'regularMaterial unless Reduce Transparency or opaqueOnly','radius':'profile.radius.customContent'}),
 'support/platform-typography': ('typeMap', ['case .standard: .default','case .expressive: .rounded','if descriptor.isEmphasized','if descriptor.isItalic'], [], {'roles':['largeTitle','title','title2','title3','headline','subheadline','body','callout','footnote','caption','caption2'],'designs':{'standard':'Font.Design.default','expressive':'Font.Design.rounded'},'modifierOrder':['bold when emphasized','italic when italic'],'limit':'system text styles resolve dynamically; illustrated text is not a native font specimen'}),
 'support/accessibility-policy': ('accessibilityPolicy', ['case systemAdaptive','case opaqueOnly','never override system preferences'], [SURFACE], {'systemAdaptive':'follows system preferences','opaqueOnly':'constrains optional package translucency to opaque','precedence':'system accessibility preference first, package constraint second'}),
 'support/profile': ('profile', ['public let typography','public let spacing','public let radius','public let semanticColors','public let surface','public let accessibility'], [], {'default':{'typography':'standard','spacingPoints':[2,8,12],'customContentRadiusPoints':12,'secondaryContent':'labelSecondary','surface':'content','accessibility':'systemAdaptive'},'groups':['typography','spacing','radius','semanticColors','surface','accessibility']}),
 'support/profile-environment': ('environment', ['DesignOSProfile.default','environment(\\.designOSProfile, profile)','self[DesignOSProfileKey.self]'], [PROFILE], {'default':'DesignOSProfile.default','injection':'view.designOSProfile(profile)','scope':'this SwiftUI view subtree; a nested injection supplies a new value'}),
 'support/radius-profile': ('radius', ['customContent.isFinite, customContent >= 0','public let customContent: CGFloat'], [PROFILE], {'property':'customContent: CGFloat','validation':'finite, nonnegative','defaultPoints':12,'scope':'package-owned non-interactive surfaces'}),
 'support/semantic-color-profile': ('secondaryRole', ['secondaryContent: DesignOSColorRole'], [PROFILE,'Sources/DesignOSApple/Platform/PlatformSemanticColor.swift'], {'property':'secondaryContent: DesignOSColorRole','default':'labelSecondary','iOS':'UIColor.secondaryLabel','macOS':'NSColor.secondaryLabelColor','scope':'supporting text in custom content'}),
 'support/spacing-profile': ('spacing', ['titleSubtitle: CGFloat','sidebarContent: CGFloat','listRowContent: CGFloat','value.isFinite && value >= 0'], [PROFILE], {'defaultPoints':{'titleSubtitle':2,'sidebarContent':8,'listRowContent':12},'validation':'finite, nonnegative','scope':'content relationships; not native container margins'}),
 'support/surface-profile': ('surfaceRole', ['role: DesignOSSurfaceRole'], ['Sources/DesignOSApple/Tokens/DesignOSSurfaceRole.swift',SURFACE,PROFILE], {'roles':['content','groupedContent','translucentContent'],'default':'content','resolution':'PlatformSurfacePolicy resolves role and accessibility preferences','scope':'custom non-interactive surfaces; no ownership of native containers'}),
 'support/typography-profile': ('typeProfile', ['case standard','case expressive','fontDesign: DesignOSFontDesign'], [TYPOGRAPHY], {'standard':'Font.Design.default','expressive':'Font.Design.rounded','preserves':'semantic text-style roles and Dynamic Type','limit':'diagram lettering is not rendered platform font evidence'}),
 'support/app-color-pair': ('colorPairs', ['public let background: DesignOSAdaptiveColor','public let foreground: DesignOSAdaptiveColor','foreground is never inferred'], [STYLE], {'members':['background','foreground'],'fallbacks':{'outgoingMessage':['surface','ink'],'disabledAction':['subtleSurface','secondaryInk']},'editorialExamples':{'outgoingMessage':['2A62E8','FFFFFF'],'disabledActionLight':['CECED0','FFFFFF']},'limit':'disabled-only pair is intentionally subdued; custom pairs require contrast checks'}),
}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def esc(value):
    return html.escape(str(value), quote=True)


class Drawing:
    def __init__(self, item, integration=False):
        self.parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}" role="img" aria-labelledby="title desc">',
                      f'<title id="title">{esc(item["name"])} — explanatory diagram</title>',
                      '<desc id="desc">Source-backed usage illustration. This is not a native screenshot, runtime rendering, interaction test or visual acceptance evidence.</desc>',
                      '<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z" fill="#176f76"/></marker></defs>']
        self.rect(0,0,WIDTH,HEIGHT,'#f5f8fa',0)
        self.rect(32,32,1136,696,'#ffffff',24,LINE)
        self.text(64,74,'Integration diagram' if integration else 'Usage illustration',18,ACCENT,700)
        self.text(64,123,item['name'],34,INK,700)
        self.text(64,156,item['id'],22,MUTED,small=True)
        self.line(64,178,1136,178,LINE)
        self.line(64,678,1136,678,LINE)
        self.text(64,710,'Illustration only · not a native capture · scaled for clarity',24,MUTED,small=True)

    def rect(self,x,y,w,h,fill='#eaf3f4',r=12,stroke=None):
        self.parts.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="2"' if stroke else '')+'/>')

    def text(self,x,y,value,size=22,color=INK,weight=400,anchor='start',small=False):
        size = size if small else max(32,size)
        self.parts.append(f'<text x="{x}" y="{y}" font-family="Arial, Helvetica, sans-serif" font-size="{size}" font-weight="{weight}" text-anchor="{anchor}" fill="{color}">{esc(value)}</text>')

    def lines(self,x,y,value,width=320,size=21,color=INK,leading=29,small=False):
        size = size if small else max(32,size)
        leading = max(leading,size+7)
        paragraphs = value if isinstance(value,list) else [value]
        lines = [line for paragraph in paragraphs for line in textwrap.wrap(paragraph,max(8,int(width/(size*.53))))]
        for i,line in enumerate(lines): self.text(x,y+i*leading,line,size,color,small=small)
        return len(lines)*leading

    def line(self,x1,y1,x2,y2,color=ACCENT,arrow=False,dash=False):
        self.parts.append(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="2"'+(' marker-end="url(#arrow)"' if arrow else '')+(' stroke-dasharray="6 5"' if dash else '')+'/>')

    def circle(self,x,y,r,fill='#c3e1e4',stroke=None):
        self.parts.append(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="2"' if stroke else '')+'/>')

    def card(self,x,y,w,h,title,body,fill='#edf5f6'):
        self.rect(x,y,w,h,fill,14,LINE)
        title_height=self.lines(x+20,y+38,title,w-40,32,INK,38)
        self.lines(x+20,y+title_height+61,body,w-40,30,MUTED,37,small=True)

    def note(self,text,y=635):
        self.lines(76,y,text,1045,24,MUTED,29,small=True)

    def finish(self):
        return '\n'.join(self.parts+['</svg>','']).encode()


def flow(d, titles, bodies, note):
    for i,(title,body) in enumerate(zip(titles,bodies)):
        x=76+i*366
        d.text(x,231,f'0{i+1}',18,ACCENT,700)
        d.card(x,256,316,277,title,body)
        if i<2:d.line(x+321,393,x+354,393,arrow=True)
    d.note(note,594)


def palette_values(source):
    names=['canvas','surface','subtleSurface','ink','secondaryInk','separator','action','actionInk']
    values={}
    for name in names:
        match=re.search(r'\b'+name+r': DesignOSAdaptiveColor\((.*?)\)',source,re.S)
        if not match:raise ValueError(f'Missing editorial color {name}')
        colors=re.findall(r'(?:uncheckedLightRGB|darkRGB):\s*0x([0-9A-F_]+)',match[1])
        if len(colors)!=2:raise ValueError(f'Unrecognized editorial color {name}')
        values[name]=[v.replace('_','') for v in colors]
    return values


def render(item, mode, values, sources):
    d=Drawing(item,item['id'].startswith('native/'))
    if mode=='section':
        d.text(80,239,'Native Section / List owns the container',23,INK,700)
        d.rect(76,285,1048,200,'#f3f6f8',16,LINE)
        d.rect(100,325,676,105,'#d6ecee');d.text(124,386,'Title · flexible, leading aligned',27)
        d.rect(814,325,286,105,'#e8e3f7');d.text(835,370,'Trailing',25);d.text(835,409,'Accessory slot',30)
        d.line(783,455,807,455,arrow=True);d.text(795,516,'8 pt HStack spacing',20,ACCENT,500,'middle')
        d.note('The helper arranges caller-owned content. It does not recreate native section metrics.',602)
    elif mode=='accessory':
        d.text(80,236,'Caller-owned accessories in one HStack',24,INK,700)
        for i,label in enumerate(['Status','Value','Action']):
            x=92+i*350;d.rect(x,306,282,152,'#e3eff1',18,LINE);d.text(x+141,390,label,28,INK,500,'middle')
            if i<2:d.line(x+291,384,x+338,384,arrow=True);d.text(x+315,493,'8 pt',21,ACCENT,500,'middle')
        d.note('Default spacing = 8 pt. A caller may supply a different spacing and any View content.',573)
    elif mode=='symbols':
        labels=['fill','circular','rounded','symbol'];xs=[298,520,750,990]
        for x,label in zip(xs,labels):d.text(x,228,label,22,INK,700,'middle')
        for j,scale in enumerate(['regular','tall']):
            cy=326+j*180;d.text(76,cy,scale,24,INK,700)
            data=values[scale]
            for i,key in enumerate(labels):
                x=xs[i]
                if key=='symbol':d.text(x,cy+10,'✦',48,ACCENT,400,'middle');label='unchanged'
                else:
                    size=data[key]*1.65
                    if key=='circular':d.circle(x,cy,size/2)
                    else:d.rect(x-size/2,cy-size/2,size,size,'#c3e1e4',data.get('roundedRadius',0)*1.65 if key=='rounded' else 0)
                    label=f'{data[key]} pt'+(f' · r {data["roundedRadius"]}' if key=='rounded' else '')
                d.text(x,cy+92,label,19,MUTED,400,'middle')
        d.note('Caller-owned imagery. Geometry illustrates frame and clip policies.',635)
    elif mode=='sidebar':
        d.text(80,237,'Two groups, one flexible separation',24,INK,700)
        d.rect(78,292,1044,196,'#f4f7f9',16,LINE)
        d.rect(102,332,245,106,'#d6ecee');d.text(124,394,'Leading content',24)
        d.rect(370,332,218,106,'#ffffff',8,LINE);d.text(479,377,'Spacer',23,MUTED,400,'middle');d.text(479,409,'min 8 pt',20,MUTED,400,'middle')
        for x,label in [(622,'Accessory 1'),(897,'Accessory 2')]:d.rect(x,332,201,106,'#e8e3f7');d.text(x+100,392,label,21,INK,400,'middle')
        d.text(855,469,'24 pt gap',18,ACCENT,500,'middle')
        d.note('Outer spacing 12 pt · spacer ≥ 8 pt · accessory spacing 24 pt.',563)
        d.note('No window controls are drawn; actions remain caller-owned.',601)
    elif mode=='adaptiveRow':
        d.text(80,227,'Enough width',23,INK,700)
        for x,w,t in [(80,220,'Label'),(316,450,'Value expands'),(782,340,'Accessory')]:d.rect(x,254,w,82,'#d6ecee');d.text(x+20,305,t,23)
        d.text(80,405,'Narrow width or accessibility text size',23,INK,700)
        for j,t in enumerate(['Label','Value','Accessory']):d.rect(80,429+j*62,560,48,'#e8e3f7',9);d.text(99,461+j*62,t,22)
        d.lines(694,455,['Same native subviews','Identity preserved','SwiftUI owns RTL placement'],400,23,MUTED,42)
        d.note('Invalid measurements also stack. The value absorbs remaining horizontal width.',641)
    elif mode=='geometry':
        for x,title,rows in [(78,'Validate inputs',['Aspect ratio: invalid → 1','Length: invalid → 0','Diameter: request → fallback → 1']), (650,'Clamp corner radius',['r ≤ half the shortest side','Negative or nonfinite r → 0'])]:d.card(x,237,472,315,title,rows)
        d.rect(680,429,220,94,'#c3e1e4',47);d.line(932,430,932,523);d.text(956,484,'94 ÷ 2',21,ACCENT)
        d.note('The 94-unit shape is an explanatory example. There is no second spacing or radius token scale.',602)
    elif mode=='clip':
        flow(d,['Caller content','Finite frame','Clip to shape'],[['Any View','Caller-owned'],['Width + height','Invalid → 0'],['clipped()','clipShape(shape)']],'The actual content frame is clipped, not a larger transparent wrapper.')
        for i in range(3):d.rect(170+i*366,440,108,55,'#bfdfe3',i*12,ACCENT)
    elif mode=='quickAction':
        flow(d,['App host','Home Screen','App routing'],[['Shortcut items','Localized titles'],['Presents actions','Owns interaction'],['Initial connection','Scene callback','App completion']],'Integration boundary: iOS / iPadOS app host. This drawing is not captured Home Screen UI.')
    elif mode=='deviceHost':
        flow(d,['App / Scene','Native host APIs','System ownership'],[['WindowGroup','Safe-area content'],['Authentication','Notifications'],['Device chrome','System prompts','Accessibility']],'Integrate with providers and system services; this metadata recipe does not render device chrome.')
    elif mode=='controlWidget':
        flow(d,['Extension host','Control configuration','System placement'],[['iOS / iPadOS 18+','ControlWidget'],['Button / toggle','App Intents'],['Bounds','Placement','Interaction']],'Host integration only: no widget wrapper, entitlement, bundle metadata or captured Control UI.')
    elif mode=='widget':
        flow(d,['Widget extension','Provider and content','System placement'],[['iOS / iPadOS 17+','WidgetBundle'],['Timeline provider','Data and content'],['Bounds / margins','Placement','Interaction']],'Host/provider integration only. The library supplies no widget entry point or visual clone.')
    elif mode=='adaptiveColor':
        colors=['B42318','FFB4AB','8C0D05','FFDAD6'];labels=['Light · standard','Dark · standard','Light · increased','Dark · increased']
        for j,(rgb,label) in enumerate(zip(colors,labels)):
            x=82+(j%2)*560;y=228+(j//2)*178;d.rect(x,y,130,114,'#'+rgb,16);d.text(x+155,y+39,label,24,INK,700);d.text(x+155,y+78,'#'+rgb,23,MUTED)
        d.note('Exact defaultDangerInk · four opaque 24-bit RGB variants · no alpha.',613)
        d.note('Omitted high-contrast values inherit standard appearance.',644)
    elif mode=='metrics':
        metrics=values['editorialPoints'];left=list(metrics.items())[:4];right=list(metrics.items())[4:]
        for col,rows in enumerate([left,right]):
            for j,(name,value) in enumerate(rows):
                x=80+col*560;y=242+j*86;d.text(x,y,name,21);d.rect(x+240,y-24,value*2,28,'#a8d2d7',5);d.text(x+430,y,f'{value} pt',22,ACCENT,700)
        d.note('Editorial preset · finite, nonnegative · action height ≥ 44 pt.',607)
        d.note('Media size > 0; radius ≤ half its size. Native geometry stays native.',640)
    elif mode=='palette':
        colors=palette_values(sources[STYLE])
        for j,(name,pair) in enumerate(colors.items()):
            x=76+(j%4)*274;y=227+(j//4)*191;d.text(x,y,name,22,INK,700)
            for i,rgb in enumerate(pair):d.rect(x+i*110,y+20,92,74,'#'+rgb,10,LINE);d.text(x+i*110,y+121,rgb,22,MUTED,small=True)
            d.text(x,y+151,'Light',23,MUTED,small=True);d.text(x+110,y+151,'Dark',23,MUTED,small=True)
        d.note('Exact editorial RGB values. Custom foreground/background pairs need contrast checks.',635)
    elif mode=='style':
        flow(d,['Profile','Palette','Metrics'],[['Semantic roles','Spacing / radius','Accessibility'],['Adaptive colors','Explicit pairs'],['Content geometry','Gaps and sizes']],'designOSAppStyle(style) injects the style and its profile into opt-in content; native controls remain native.')
    elif mode=='preferences':
        fields=[('reduceMotion','Bool'),('reduceTransparency','Bool'),('differentiateWithoutColor','Bool'),('contrast','standard | increased')]
        for j,(name,t) in enumerate(fields):x=80+(j%2)*560;y=240+(j//2)*165;d.card(x,y,480,127,name,[t])
        d.note('Immutable preferences feed rendering policies. This type does not set or override accessibility settings.',626)
    elif mode=='semanticMap':
        headers=['Semantic role','iOS / iPadOS','macOS'];xs=[82,427,790]
        for x,h in zip(xs,headers):d.text(x,231,h,21,ACCENT,700)
        for j,row in enumerate(values['mappings']):
            y=290+j*110;d.line(80,y+61,1115,y+61,LINE)
            for x,key in zip(xs,['role','iOS','macOS']):d.text(x,y,row[key].replace('UIColor.','').replace('NSColor.',''),29,INK,small=True)
        d.note('Names map to adaptive platform providers. Fixed RGB colors would misrepresent these roles.',639)
    elif mode=='surfaceRole':
        for x,title,body in [(80,'content',['Opaque semantic','content surface']), (446,'groupedContent',['Opaque grouped','content surface']), (812,'Translucent',['Material / opaque','Accessibility-aware'])]:
            d.card(x,257,310,280,title,body)
        d.note('Role intent → platform appearance and accessibility.',600)
        d.note('Custom, non-interactive content only; native containers stay native.',637)
    elif mode=='accessibilityPolicy':
        d.card(80,250,493,300,'systemAdaptive',['Follow system preferences','Material only when allowed'])
        d.card(628,250,493,300,'opaqueOnly',['Apply package constraint','Optional material → opaque'])
        d.note('System preferences win. Package policy can never force translucency back on.',606)
    elif mode=='surfacePolicy':
        d.text(80,230,'Optional translucent custom content',24,INK,700)
        d.card(80,269,305,266,'Requested role',['content','grouped content','translucent'])
        d.card(446,269,310,266,'Policy gate',['Reduce Transparency?','Opaque-only profile?'])
        d.card(817,269,305,266,'Resolved surface',['Opaque content','or regularMaterial'])
        d.line(392,400,432,400,arrow=True);d.line(763,400,803,400,arrow=True)
        d.note('System preferences apply before package constraints.',599)
        d.note('Custom content only; native containers stay native.',637)
    elif mode=='typeMap':
        d.text(82,232,'Semantic role → Font.system(textStyle, design:)',24,INK,700)
        for j,(role,size) in enumerate([('largeTitle',44),('headline',38),('body',34),('caption',28)]):
            y=301+j*72;d.text(84,y,role,20,MUTED);d.text(327,y,'Readable content',size,small=True)
        d.card(750,273,364,274,'Font modifiers',['Emphasized → bold','Italic → italic','standard → .default','expressive → .rounded'])
        d.note('Representative role subset. Lettering here is schematic; system sizing and Dynamic Type resolve at runtime.',640)
    elif mode=='profile':
        rows=[('typography','standard'),('spacing','2 / 8 / 12 pt'),('radius','12 pt radius'),('semanticColors','labelSecondary'),('surface','content'),('accessibility','systemAdaptive')]
        for j,(title,body) in enumerate(rows):x=80+(j%3)*366;y=237+(j//3)*176;d.card(x,y,312,134,title,[body])
        d.note('DesignOSProfile.default: six immutable typed groups, injected together into a view subtree.',639)
    elif mode=='environment':
        d.card(412,216,372,112,'Environment default',['Default profile'])
        d.line(598,330,598,367,arrow=True)
        d.card(292,382,615,115,'Parent subtree',['.designOSProfile(customProfile)'])
        d.line(402,499,279,545,arrow=True);d.line(791,499,895,545,arrow=True)
        d.rect(80,554,436,76,'#d6ecee');d.text(104,600,'Child inherits customProfile',22)
        d.rect(635,554,486,76,'#e8e3f7');d.text(655,600,'Nested profile override',21)
    elif mode=='radius':
        for i,(r,label) in enumerate([(0,'0 pt · valid'),(12,'12 pt · default'),(28,'28 pt · caller example')]):
            x=82+i*365;d.rect(x,289,292,178,'#c3e1e4',r*2,ACCENT);d.text(x+146,521,label,22,INK,500,'middle')
        d.note('customContent must be finite and nonnegative. It styles only package-owned non-interactive surfaces.',617)
    elif mode=='secondaryRole':
        d.text(80,231,'One semantic role for supporting text',24,INK,700)
        d.card(80,281,380,243,'secondaryContent',['DesignOSColorRole','Default: labelSecondary'])
        d.line(471,356,589,307,arrow=True);d.line(471,443,589,486,arrow=True)
        d.card(605,245,514,137,'iOS / iPadOS',['UIColor.secondaryLabel'])
        d.card(605,422,514,137,'macOS',['NSColor.secondaryLabelColor'])
        d.note('The platform resolves appearance and contrast. The profile stores intent, not a fixed gray.',638)
    elif mode=='spacing':
        for j,(name,gap) in enumerate(values['defaultPoints'].items()):
            y=245+j*119;d.text(80,y+31,name,23,INK,700);d.rect(428,y,200,50,'#d6ecee',8);d.rect(628+gap*5,y,200,50,'#e8e3f7',8);d.text(934,y+32,f'{gap} pt',27,ACCENT,700)
        d.note('Default profile relationships; the gap is enlarged for readability. Each value must be finite and ≥ 0.',641)
    elif mode=='typeProfile':
        d.card(80,241,493,315,'standard',['Maps to Font.Design.default','Keeps semantic text styles']);d.card(628,241,493,315,'expressive',['Maps to Font.Design.rounded','Keeps semantic text styles'])
        d.text(107,463,'Aa',68,ACCENT);d.text(655,463,'Aa',68,ACCENT)
        d.note('Font samples are schematic lettering, not native font renders. Dynamic Type remains system-owned.',620)
    elif mode=='colorPairs':
        for x,title,bg,fg,limit in [(80,'Outgoing message','2A62E8','FFFFFF','Explicit message emphasis'),(627,'Disabled action · light','CECED0','FFFFFF','Disabled-only; not active text')]:
            d.text(x,236,title,23,INK,700);d.rect(x,266,493,162,'#'+bg,18,LINE);d.text(x+246,361,'Foreground on background',25,'#'+fg,500,'middle');d.text(x,474,f'background #{bg}',21,MUTED);d.text(x,510,f'foreground #{fg}',21,MUTED);d.text(x,555,limit,21,ACCENT)
        d.note('Exact editorial light examples. A pair selects both adaptive colors; custom combinations need contrast checks.',633)
    else:raise ValueError(f'No renderer for {mode}')
    return d.finish()


def outputs():
    catalog=json.loads((ROOT/'docs/marketing/component-catalog.json').read_text())
    items={i['id']:i for group in catalog['groups'] for i in group['items']}
    source_pins={i['source']['path']:i['source'] for i in items.values()}
    rendered={};records=[]
    for entry_id,(mode,needles,extras,values) in SPECS.items():
        item=items[entry_id];source=item['source'];raw=(ROOT/source['path']).read_bytes()
        if digest(raw)!=source['sha256']:raise ValueError(f'Stale source pin: {entry_id}')
        text=raw.decode()
        for needle in needles:
            if needle not in text:raise ValueError(f'Source declaration changed: {entry_id}: {needle}')
        sources={source['path']:text};support=[]
        for path in extras:
            data=(ROOT/path).read_bytes();sources[path]=data.decode()
            pin=source_pins[path]
            if digest(data)!=pin['sha256']:raise ValueError(f'Stale supporting source: {path}')
            support.append({'path':path,'commit':pin['commit'],'sha256':digest(data)})
        assertions = []
        if mode=='adaptiveColor':
            assertions += [(PALETTE, token) for token in ('0xB4_2318','0xFF_B4AB','0x8C_0D05','0xFF_DAD6')]
        if mode in ('spacing','profile'):
            assertions += [(PROFILE, token) for token in ('uncheckedTitleSubtitle: 2','sidebarContent: 8','listRowContent: 12')]
        if mode in ('radius','profile'):
            assertions += [(PROFILE, 'uncheckedCustomContent: 12')]
        if mode in ('secondaryRole','profile'):
            assertions += [(PROFILE, 'secondaryContent: .labelSecondary')]
        if mode in ('surfaceRole','profile'):
            assertions += [(PROFILE, 'surface: DesignOSSurfaceProfile(role: .content)')]
        if mode=='typeProfile':
            assertions += [(TYPOGRAPHY, token) for token in ('case .standard: .default','case .expressive: .rounded')]
        if mode=='colorPairs':
            assertions += [(STYLE, token) for token in ('uncheckedLightRGB: 0x2A_62E8','uncheckedLightRGB: 0xCE_CED0','foreground: DesignOSAdaptiveColor(uncheckedLightRGB: 0xFF_FFFF')]
        for path,token in assertions:
            if token not in sources[path]:raise ValueError(f'Stale illustrated value: {path}: {token}')
        # Numeric preset values are also asserted against the supporting implementation.
        if STYLE in sources:
            if mode in ('palette','metrics','colorPairs'):palette_values(sources[STYLE])
            if mode=='metrics':
                for key,value in values['editorialPoints'].items():
                    name='uncheckedPageInset' if key=='pageInset' else key
                    if f'{name}: {value}' not in sources[STYLE]:raise ValueError(f'Stale metric {name}')
        if mode=='palette':values={**values,'editorialRGB':palette_values(sources[STYLE])}
        filename=entry_id.replace('/','-')+'.svg';data=render(item,mode,values,sources)
        parsed=ET.fromstring(data)
        for node in parsed.iter():
            if node.tag.split('}')[-1] in ('script','foreignObject','image','use'):raise ValueError('Unsafe SVG element')
            if any(k.startswith('on') or k.endswith('href') for k in node.attrib):raise ValueError('Unsafe SVG attribute')
        if b'http' in data.replace(b'http://www.w3.org/2000/svg',b''):raise ValueError('External SVG reference')
        rendered[filename]=data
        records.append({'entryId':entry_id,'type':'integration-diagram' if entry_id.startswith('native/') else 'usage-illustration','kind':'integration-diagram' if entry_id.startswith('native/') else 'usage-illustration','label':'Integration diagram' if entry_id.startswith('native/') else 'Usage illustration','description':item['summary'],'file':filename,'width':WIDTH,'height':HEIGHT,'sha256':digest(data),'byteSize':len(data),'source':{'path':source['path'],'commit':source['commit'],'sha256':source['sha256'],'symbol':item['symbol']},'supportingSources':support,'sourceBackedValues':values,'sourceValues':values,'checkedDeclarations':needles,'explanatoryLimits':['Code-driven explanatory SVG; not a native screenshot or rendered SwiftUI specimen.','Diagram geometry and lettering are scaled for explanation; runtime appearance, interaction and accessibility acceptance are not established.','Only documented source relationships are illustrated; app state and system/provider integration remain caller-owned.']})
    manifest={'version':1,'sourceCommit':catalog['sourceCommit'],'generator':'scripts/generate-catalog-illustrations.py','scope':'28 source-only catalog entries with explicit explanatory visuals; no native-capture status is changed.','assets':records}
    rendered['manifest.json']=(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n').encode()
    return rendered


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--check',action='store_true');args=parser.parse_args()
    if OUT.is_symlink() or OUT.resolve()!=OUT:
        raise ValueError('Symlinked illustration directory or ancestor')
    expected=outputs()
    if args.check:
        actual={p.name for p in OUT.iterdir()} if OUT.is_dir() else set()
        if actual!=set(expected):raise ValueError('Illustration inventory differs from deterministic generator')
        for name,data in expected.items():
            if (OUT/name).is_symlink() or (OUT/name).read_bytes()!=data:raise ValueError(f'Stale illustration: {name}')
    else:
        OUT.mkdir(parents=True,exist_ok=True)
        unexpected={p.name for p in OUT.iterdir()}-set(expected)
        if unexpected:raise ValueError(f'Refusing to overwrite unexpected illustration files: {sorted(unexpected)}')
        for name,data in expected.items():
            if (OUT/name).is_symlink():raise ValueError(f'Symlinked illustration output: {name}')
            (OUT/name).write_bytes(data)
    print(f'PASS: {len(expected)-1} deterministic source-pinned explanatory SVGs; {sum(len(v) for v in expected.values()):,} bytes including manifest.')
    return 0


if __name__=='__main__':
    try:sys.exit(main())
    except (ValueError,OSError,KeyError) as error:
        print(f'E_CATALOG_ILLUSTRATION: {error}',file=sys.stderr);sys.exit(1)
