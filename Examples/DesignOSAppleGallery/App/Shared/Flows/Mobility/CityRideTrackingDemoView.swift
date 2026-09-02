import SwiftUI

struct CityRideTrackingDemoView: View {
  @State private var activeNotice: CityRideNotice?

  var body: some View {
    GeometryReader { proxy in
      let mapSize = CGSize(width: proxy.size.width, height: proxy.size.height * 0.39)
      VStack(spacing: 0) {
        ZStack {
          MobilityMapField(style: .cityTracking)
          trackingMapOverlay(size: mapSize)
        }
        .frame(height: mapSize.height)
        airportAdvertisement
        MobilitySheet { trackingSheet }
          .frame(maxHeight: .infinity)
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
    }
    .background(MobilityDemoTheme.paper)
    .ignoresSafeArea(edges: [.top, .bottom])
    #if os(iOS)
      .toolbarBackground(.hidden, for: .navigationBar)
    #endif
    .localDemoRootIdentifier("design-os.demo.mobility.city-ride.tracking")
    .alert(item: $activeNotice) { notice in
      Alert(
        title: Text(notice.title),
        message: Text(notice.message),
        dismissButton: .cancel(Text("Done")))
    }
  }

  private func trackingMapOverlay(size: CGSize) -> some View {
    ZStack {
      HStack(spacing: 10) {
        Button {
          activeNotice = .route
        } label: {
          HStack(spacing: 10) {
            Circle().fill(.gray.opacity(0.25)).frame(width: 38, height: 38)
              .overlay(Image(systemName: "building.2.crop.circle.fill").foregroundStyle(.green))
            VStack(alignment: .leading, spacing: 1) {
              Text("Go to North Terminal").font(.caption.weight(.semibold)).lineLimit(1)
              Text("Open directions").font(.caption).foregroundStyle(MobilityDemoTheme.cityGreen)
            }
          }
        }
        .buttonStyle(LocalDemoPressButtonStyle())
        .accessibilityLabel("Open directions to North Terminal")
        Spacer()
        Button {
          activeNotice = .route
        } label: {
          Image(systemName: "ellipsis").font(.body).frame(width: 44, height: 44)
        }
        .buttonStyle(LocalDemoPressButtonStyle())
        .accessibilityLabel("Route options")
      }
      .padding(5).frame(width: max(0, min(size.width - 92, 256)), height: 48)
      .background(MobilityDemoTheme.controlFill, in: Capsule())
      .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
      .position(x: size.width * 0.53, y: 56)

      Button {
        activeNotice = .recenter
      } label: {
        MobilityCircularControl(symbol: "location.fill", label: "Center on route")
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .position(x: size.width - 40, y: 103)

      Button {
        activeNotice = .safety
      } label: {
        Label("Safety Center", systemImage: "shield.checkered")
          .font(.caption.weight(.semibold))
          .foregroundStyle(MobilityDemoTheme.cityGreen)
          .padding(.horizontal, 12)
          .frame(minHeight: 44)
          .background(MobilityDemoTheme.safetyFill, in: Capsule())
      }
      .buttonStyle(.plain)
      .buttonStyle(LocalDemoPressButtonStyle())
      .accessibilityIdentifier("design-os.demo.mobility.city-ride.safety-center")
      .position(x: 86, y: max(22, size.height - 28))
    }
  }

  private var airportAdvertisement: some View {
    Button {
      activeNotice = .airport
    } label: {
      HStack(spacing: 12) {
        VStack(alignment: .leading, spacing: 2) {
          Text("Schedule your airport ride ahead").font(.caption.weight(.semibold))
          Text("Relax knowing pickup is planned.").font(.caption)
        }
        Spacer()
        Image(systemName: "airplane.departure")
          .font(.title2).foregroundStyle(MobilityDemoTheme.cityGreen)
      }
      .padding(.horizontal, 14).frame(maxWidth: .infinity, minHeight: 52)
      .background(MobilityDemoTheme.airportFill)
    }
    .buttonStyle(.plain)
    .buttonStyle(LocalDemoPressButtonStyle())
    .accessibilityLabel("Schedule airport ride advertisement")
    .accessibilityIdentifier("design-os.demo.mobility.city-ride.airport-advertisement")
  }

  private var trackingSheet: some View {
    VStack(spacing: 12) {
      Capsule().fill(.secondary.opacity(0.55)).frame(width: 40, height: 4)
      HStack(alignment: .firstTextBaseline) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Driver is on the way").font(.headline)
          Text("Central District – North Terminal").font(.caption).foregroundStyle(.secondary)
        }
        Spacer()
        Text("3 min").font(.title3.bold())
      }
      .accessibilityIdentifier("design-os.demo.mobility.city-ride.driver-eta")

      VStack(spacing: 12) {
        HStack(spacing: 12) {
          Circle().fill(.gray.opacity(0.14)).frame(width: 52, height: 52)
            .overlay(Image(systemName: "person.fill").foregroundStyle(.gray))
          Image(systemName: "bolt.car.fill").font(.title2).foregroundStyle(
            MobilityDemoTheme.cityGreen)
          Spacer()
          VStack(alignment: .trailing, spacing: 4) {
            Text("Mina · Electric Plus").font(.subheadline)
            Label("5.0", systemImage: "star.fill").font(.caption).foregroundStyle(.yellow)
          }
        }
        HStack(spacing: 10) {
          Button {
            activeNotice = .message
          } label: {
            Label("Message driver", systemImage: "message")
              .font(.subheadline.weight(.semibold)).foregroundStyle(MobilityDemoTheme.cityGreen)
              .frame(maxWidth: .infinity, minHeight: 44)
              .overlay(Capsule().stroke(MobilityDemoTheme.cityGreen, lineWidth: 1))
          }
          .buttonStyle(.plain)
          .buttonStyle(LocalDemoPressButtonStyle())
          .accessibilityIdentifier("design-os.demo.mobility.city-ride.message-driver")

          Button {
            activeNotice = .call
          } label: {
            Image(systemName: "phone.fill").foregroundStyle(.white).frame(width: 48, height: 44)
              .background(MobilityDemoTheme.cityGreen, in: Capsule())
          }
          .buttonStyle(.plain)
          .buttonStyle(LocalDemoPressButtonStyle())
          .accessibilityLabel("Call driver")
          .accessibilityIdentifier("design-os.demo.mobility.city-ride.call-driver")
        }
      }
      .padding(14)
      .background(MobilityDemoTheme.controlFill, in: RoundedRectangle(cornerRadius: 16))
      .overlay(RoundedRectangle(cornerRadius: 16).stroke(.gray.opacity(0.18)))
      .localDemoRootIdentifier("design-os.demo.mobility.city-ride.contact-card")

      CityRideArrivalPromotion {
        activeNotice = .arrival
      }
    }
  }
}
