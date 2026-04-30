//
//  ContentView.swift
//  Music App
//
//  Created by Nathan Davis on 10/31/23.
//

import SwiftUI
import AudioToolbox


struct ContentView: View {
    let chords: [[UInt8]] = [[60, 64, 67], [62, 65, 69], [64, 67, 71]]
     // C, D, and E major chords
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(.white)
                VStack {
                    Text("Ear Trainer!")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                    Spacer()
                    ScrollView {
                        NavigationLink(destination: IndividualIntervalView()) {
                            Text("Individual Intervals")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: SequenceView()) {
                            Text("Intervals")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: MelodyView()) {
                            Text("Melodies")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: SingleChordView()) {
                            Text("Single Chords")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: DiatonicChordView()) {
                            Text("Diatonic Chords")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: VocalView()) {
                            Text("Vocals")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: WhistleView()) {
                            Text("Whistling")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: OcarinaView()) {
                            Text("Ocarina")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: TallyMethodView()) {
                            Text("Tally Method")
                                .capsuleButtonStyle()
                        }
                        //                    ScrollView(showsIndicators: false) {
                        //                    }
                        //                    .padding()
                    }
                }
            }
        }

    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
