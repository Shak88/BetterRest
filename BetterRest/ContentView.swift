//
//  ContentView.swift
//  BetterRest
//
//  Created by Shokri Alnajjar on 13/04/2022.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    

    
    var body: some View {
        NavigationView{
            Form {
                Section(header : Text("When do you want to wake up") ) {
                    
                    DatePicker("Please Enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section(header : Text("Desired amount of sleep")) {
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section(header : Text("Daily Coffee intake")) {
                    
                    //Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                    Picker("number of coffee cups",selection: $coffeeAmount){
                        ForEach(0..<21){
                            Text($0 == 1 ? "1 Cup" : "\($0) Cups")
                        }
                    }
                    
                }
                
                VStack(alignment: .leading , spacing: 10){
                    let sleepTime = calculateBedtime()
                    Text("Recommended Sleep Time")
                        .font(.headline)
                    
                    Text(sleepTime.formatted(date: .omitted, time: .shortened))
                }
            }
            .navigationTitle("BetterRest")
            //.toolbar{
            //    Button("Calculate", action: calculateBedtime)
            //}
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        
    }
    }
    
    func calculateBedtime() -> Date{
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime
            
            //alertTitle = "Your ideal bedtime is..."
            //alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            
            alertTitle = "error"
            alertTitle = " sorry there was a problem calculating your bedtime"
            showingAlert = true
        }
        //showingAlert = true
        return Date.now
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
