//
//  ContentView.swift
//  CoreDataMVVM
//
//  Created by Jonni Akesson on 2023-02-25.
//

import SwiftUI
import CoreData

class CoreDataViewModel: ObservableObject {
    
    let container: NSPersistentContainer
    @Published var fruits = [Fruit]()
    
    init() {
        container = NSPersistentContainer(name: "CoreDataMVVM")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("error loading core data \(error)")
            } else {
                print("succesfuly loaded core data")
            }
        }
        fetchFruits()
    }
    
    func fetchFruits() {
        let request = NSFetchRequest<Fruit>(entityName: "Fruit")
        do{
            fruits = try container.viewContext.fetch(request)
        } catch {
            print("error fetching fruits \(error.localizedDescription)")
        }
    }
    
    func addFruit(text: String) {
        let newFruit = Fruit(context: container.viewContext)
        newFruit.name = text
        saveData()
    }
    
    func deleteFruit(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let fruit = fruits[index]
        container.viewContext.delete(fruit)
        saveData()
    }
    
    func updatFruit(fruit: Fruit) {
        let currentName = fruit.name ?? ""
        let newName = currentName + "!"
        fruit.name = newName
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchFruits()
        } catch {
            print("error saving \(error.localizedDescription)")
        }
    }
}

struct ContentView: View {
    @StateObject var coreDataViewModel = CoreDataViewModel()
    @State var textFieldText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Add fruit", text: $textFieldText)
                    .font(.headline)
                    .padding(.leading)
                    .frame(height: 55)
                    .background(Color(uiColor: .systemGroupedBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button {
                    guard !textFieldText.isEmpty else { return }
                    coreDataViewModel.addFruit(text: textFieldText)
                    textFieldText = ""
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(.pink)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                List {
                    ForEach(coreDataViewModel.fruits) { fruit in
                        Text(fruit.name ?? "NO NAME")
                            .onTapGesture {
                                coreDataViewModel.updatFruit(fruit: fruit)
                            }
                    }
                    .onDelete(perform: coreDataViewModel.deleteFruit)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Fruits")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
