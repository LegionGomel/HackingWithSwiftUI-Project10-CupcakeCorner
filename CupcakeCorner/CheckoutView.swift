//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Yuri Ershov on 18.01.22.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var order: Order
    
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("Your total is \(order.cost, format: .currency(code: "USD"))")
                    .font(.title)
                
                Button("Place Order"){
                    Task {
                        await placeOrder()
                    }
                }
                    .padding()
            }
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank you!", isPresented: $showingConfirmation) {
            Button("OK", action: {})
        } message: {
            Text(confirmationMessage)
        }
    }
    // asyncronous function to send order object as a JSON in background
    func placeOrder() async {
        // try to encode order object
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        // create URLRequest with url string
        var request = URLRequest(url: url)
        // set value type to json
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        // configure request type to send data
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            // handle the result and show as confirmationMessage
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            confirmationMessage = "Your order for \(decodedOrder.quantity) x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way."
            showingConfirmation = true
        } catch {
            confirmationMessage = "Something wrong with your order. Please check the internet connection."
            showingConfirmation = true
            print("Checkout failed")
        }
    }
    
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CheckoutView(order: Order())
        }
    }
}
