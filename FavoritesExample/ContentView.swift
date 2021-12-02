//
//  ContentView.swift
//  FavoritesExample
//
//  Created by Aris Koxaras on 30/11/21.
//

import SwiftUI

//
// NOTE:
// In your app delegate or 'App' class set .environmentObject(ItemStore.shared) in the contentView
//


// This could be a struct also.
class Item {
    var id: UUID
    var name: String

    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

// Our database. The IDs must persist across launches
var sampleItems1 = [Item(id: UUID(uuidString: "bf85d038-cb02-494b-8cd2-e665d72b30f4")!, name: "item1"),
                    Item(id: UUID(uuidString: "923fda1b-d58d-4aec-b279-a7bf21b5b354")!, name: "item2"),
                    Item(id: UUID(uuidString: "c3fc1ca6-97b0-4717-8d67-ce5fca05da5a")!, name: "item3"),
                    Item(id: UUID(uuidString: "a687d3f9-f36a-466c-a9b6-4ab493eaa7a3")!, name: "item4"),
                    Item(id: UUID(uuidString: "4c7fff89-0dc2-457f-806a-d87c384f56f0")!, name: "item5"),
                    Item(id: UUID(uuidString: "fb391cc9-4a48-4d7c-b00b-4cd18b18f460")!, name: "item6")]

// The main class that handles the items & favorites
class ItemStore: ObservableObject {
    @Published private(set) var items: [Item] = []
    @Published private(set) var favoriteItemIds: [UUID] = []

    static let shared = ItemStore(items: sampleItems1)

    init(items: [Item]) {
        self.items = items

        // load from user defaults
        let savedFavoriteItems = UserDefaults.standard.array(forKey: "favorites") as? [String]
        self.favoriteItemIds = savedFavoriteItems?.map { UUID(uuidString: $0)! } ?? []
    }

    func addFavorite(item: Item) {
        favoriteItemIds.append(item.id)
        saveFavorites()
    }

    func removeFavorite(item: Item) {
        if let idx = favoriteItemIds.firstIndex(where: { $0 == item.id }) {
            favoriteItemIds.remove(at: idx)
        }
        saveFavorites()
    }

    func isFavorite(item: Item) -> Bool {
        return favoriteItemIds.contains(where: { $0 == item.id })
    }

    func getItem(with id: UUID) -> Item? {
        if let idx = items.firstIndex(where: { $0.id == id }) {
            return items[idx]
        }
        return nil
    }

    private func saveFavorites() {
        UserDefaults.standard.setValue(favoriteItemIds.map { $0.uuidString }, forKey: "favorites")
    }
}

struct ContentView: View {
    @EnvironmentObject var itemStore: ItemStore

    var body: some View {
        TabView {
            ItemList()
                .tabItem {
                   Image(systemName: "list.bullet")
                   Text("Items")
                 }
            FavoritesList()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorites")
                }
        }
    }
}

struct ItemList: View {
    @EnvironmentObject var itemStore: ItemStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(itemStore.items, id: \.id) { item in
                    let isFavorite = itemStore.isFavorite(item: item)
                    ItemView(item: item,
                             onTap: {
                        isFavorite ? itemStore.removeFavorite(item: item) : itemStore.addFavorite(item: item)
                    },
                             isFavorite: isFavorite)
                }
            }
        }
    }
}

struct ItemView: View {
    @State var item: Item
    var onTap: () -> ()
    var isFavorite: Bool

    var body: some View {
        HStack {
            Text(item.name)
            Button(action: {
                onTap()
            }, label: {
                isFavorite ? Image(systemName: "heart.fill") : Image(systemName: "heart")
            })
        }
    }
}

// This is duplicated. we could be using the ItemView with little modifications
struct FavoriteItemView: View {
    @State var item: Item
    var onTap: () -> ()

    var body: some View {
        HStack {
            Text("Favorite")
            Text(item.name)
            Button(action: {
                onTap()
            }, label: {
                Image(systemName: "heart.fill")
            })
        }
    }
}

struct FavoritesList: View {
    @EnvironmentObject var itemStore: ItemStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(itemStore.favoriteItemIds, id: \.self) { favoriteId in
                    if let item = itemStore.getItem(with: favoriteId) {
                        FavoriteItemView(item: item,
                                         onTap: {
                            itemStore.removeFavorite(item: item)
                        })
                    } // TODO: handle favorite item not found
                }
            }.animation(.default, value: itemStore.favoriteItemIds)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
