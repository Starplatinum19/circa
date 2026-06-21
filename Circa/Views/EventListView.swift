import SwiftUI

struct EventListView: View {
    @EnvironmentObject var viewModel: EventsViewModel
    @EnvironmentObject var locationManager: LocationManager
    @Binding var searchQuery: String
    @Binding var selectedCity: String

    private var filteredEvents: [Event] {
        viewModel.events.filter { event in
            event.city.localizedCaseInsensitiveContains(selectedCity) || selectedCity.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                HStack {
                    TextField("Search events by city or ZIP", text: $searchQuery)
                        .padding(.leading, 20)
                        .padding(.vertical, 12)
                    Button(action: {
                        selectedCity = locationManager.currentCity
                        searchQuery = locationManager.currentCity
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 16)
                }
                .background(Color(.systemGray6))
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(.separator), lineWidth: 0.3)
                )
                .onSubmit {
                    selectedCity = searchQuery
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // Event List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredEvents) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            EventCardView(event: event, locationManager: locationManager)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
        }
    }
}

#Preview {
    struct Wrapper: View {
        @StateObject var vm = EventsViewModel()
        @StateObject var lm = LocationManager()
        @State var searchQuery: String = ""
        @State var selectedCity: String = ""
        var body: some View {
            EventListView(searchQuery: $searchQuery, selectedCity: $selectedCity)
                .environmentObject(vm)
                .environmentObject(lm)
        }
    }
    return Wrapper()
}
