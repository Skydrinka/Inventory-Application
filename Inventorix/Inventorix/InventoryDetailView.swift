//
//  InventoryDetailView.swift
//  Inventorix
//
//  Created by Nikitas Kaouslides on 18/05/2024.
//


import SwiftUI
import CoreData

struct InventoryDetailView: View {
    @ObservedObject var category: Category
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack {
            TextField("Category Name", text: Binding(
                get: { category.name ?? "" },
                set: { category.name = $0; saveContext() }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            List {
                ForEach(category.itemsArray, id: \.self) { item in
                    HStack {
                        TextField("Item Name", text: Binding(
                            get: { item.name ?? "" },
                            set: { item.name = $0; saveContext() }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                        Spacer()

                        Stepper(value: Binding(
                            get: { Int32(item.quantity) },
                            set: { item.quantity = Int32($0); saveContext() }
                        ), in: 0...Int32.max) {
                            Text("\(item.quantity)")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .navigationTitle(category.name ?? "Category")
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.name = "New Item"
            newItem.quantity = 0
            newItem.category = category
            saveContext()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { category.itemsArray[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension Category {
    var itemsArray: [Item] {
        let set = items as? Set<Item> ?? []
        return set.sorted {
            $0.name ?? "" < $1.name ?? ""
        }
    }
}

struct InventoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let category = Category(context: context)
        category.name = "Preview Category"
        let item = Item(context: context)
        item.name = "Preview Item"
        item.quantity = 10
        item.category = category
        return InventoryDetailView(category: category).environment(\.managedObjectContext, context)
    }
}
