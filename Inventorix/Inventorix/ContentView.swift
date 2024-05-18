//
//  ContentView.swift
//  Inventorix
//
//  Created by Nikitas Kaouslides on 18/05/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) var categories: FetchedResults<Category>
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .padding(.top, 20)
                
                Text("Here's your current inventory")
                    .font(.headline)
                    .padding(.top, 10)
                
                List {
                    ForEach(categories) { category in
                        NavigationLink(destination: InventoryDetailView(category: category)) {
                            CategoryRow(category: category)
                        }
                    }
                    .onDelete(perform: deleteCategories)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: addCategory) {
                            Label("Add Category", systemImage: "plus")
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Inventory")
        }
    }
    
    private func addCategory() {
        withAnimation {
            let newCategory = Category(context: viewContext)
            newCategory.name = "New Category"
            saveContext()
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        withAnimation {
            offsets.map { categories[$0] }.forEach(viewContext.delete)
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

struct CategoryRow: View {
    var category: Category
    
    var body: some View {
        HStack {
            Text(category.name ?? "Unknown Category")
            Spacer()
            Text("\(category.itemsArray.count)")
            Image(systemName: "chevron.right")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
