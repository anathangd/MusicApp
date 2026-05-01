//
//  WhistleView.swift
//  Music App
//
//  Created by Nathan Davis on 1/22/24.
//

import SwiftUI
import AudioToolbox

struct WhistleView: View {
    //whistle range: 69-80
    @State var notes: [UInt8] = [71,69,62,72,71,69,67]
    @State var rootNoteLetter = "G"
    @State var rootNote: UInt8 = 72
    @State var nextNote: UInt8 = 72
    @State var counter = 0
    @State var howMany = 2  //two extra notes after the root, loop starts at 0
    @State var answer = ["Perfect fifth", "minor third"]
    @State var diatonicAnswer = ["1", "7", "5", "8"]
    @State var diatonicAnswerString = "1, 7, 5"
    @State var diatonic = false
    @State var tempo = 150.0
    @State var fourNote = false
    @State var individual = false
    @State var interval = "Major third"
    @State var prompt = "Descending Major third from:"
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Toggle("", isOn: $individual)
                        .padding(.horizontal)
                }
                Spacer()
            }
            VStack {
                Text("Score: " + String(counter))
                    .font(.system(size: 30))
                    .padding()
                Text("Root Note:")
                    .font(.system(size: 30))
                Text(rootNoteLetter)
                    .font(.system(size: 80))
                Button("Play Sequence") {
                    playSequence()
                }
                .foregroundStyle(.black)
                .padding()
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                HStack {
                    Button("First") {
                        playFirst()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .foregroundStyle(.black)
                    
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Second") {
                        playSecond()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .foregroundStyle(.black)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if fourNote {
                        Button("Third") {
                            playThird()
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                        .foregroundStyle(.black)
                        .background(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                Button("next") {
                    next()
                }.padding()
            }
            VStack {
                Spacer()
                Slider(value: $tempo,
                       in: 40...200,
                       step: 1)
                .padding()
                if diatonic {
                    Text(diatonicAnswerString)
                            .font(.caption)
                } else {
                    Text(String(answer[0]) + (howMany != 1 ? ", " + answer[1] : ""))
                        .font(.caption)
                }
                
            }
            if individual {
                Rectangle()
                    .foregroundStyle(Color(.systemBackground))
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Spacer()
                        Toggle("", isOn: $individual)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                VStack {
                    Text("Score: " + String(counter))
                        .font(.system(size: 30))
                        .padding()
                    Text(prompt)
                        .font(.system(size: 30))
                    Text(rootNoteLetter)
                        .font(.system(size: 80))
                    Button("Play Answer") {
                        playFirst()
                    }
                    .foregroundStyle(.black)
                    .padding()
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("next") {
                        next()
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            next()
            counter = 0
        }
    }
    
    func next() {
        fourNote = false
        notes.removeAll()
        rootNote = UInt8(Int.random(in: 71...78)) //leave room for my whistling range
        notes.append(rootNote)
        var previousNote = rootNote
        for decision in 0..<howMany {
            var done = false
            while !done { //have an audible range
                nextNote = UInt8(Int.random(in: 1...12))
                let coinflip = Int.random(in: 1...2)
                if coinflip == 1 { //descending
                    nextNote = previousNote - nextNote
                    if nextNote > 68 {
                        done = true
                    }
                } else { //ascending
                    nextNote = previousNote + nextNote
                    if nextNote <= 80 {
                        done = true
                    }
                }
            }
            notes.append(nextNote)
            switch abs(Int(previousNote) - Int(nextNote)) {
            case 1: answer[decision] = "minor second"
            case 2: answer[decision] = "Major second"
            case 3: answer[decision] = "minor third"
            case 4: answer[decision] = "Major third"
            case 5: answer[decision] = "Perfect fourth"
            case 6: answer[decision] = "tritone"
            case 7: answer[decision] = "Perfect fifth"
            case 8: answer[decision] = "minor sixth"
            case 9: answer[decision] = "Major sixth"
            case 10: answer[decision] = "minor seventh"
            case 11: answer[decision] = "Major seventh"
            case 12: answer[decision] = "Perfect octave"
            default: answer[decision] = "not found"
            }
            previousNote = nextNote
        }
        switch rootNote % 12 {
        case 0: rootNoteLetter = "C"
        case 1: rootNoteLetter = "D♭"
        case 2: rootNoteLetter = "D"
        case 3: rootNoteLetter = "E♭"
        case 4: rootNoteLetter = "E"
        case 5: rootNoteLetter = "F"
        case 6: rootNoteLetter = "G♭"
        case 7: rootNoteLetter = "G"
        case 8: rootNoteLetter = "A♭"
        case 9: rootNoteLetter = "A"
        case 10: rootNoteLetter = "B♭"
        case 11: rootNoteLetter = "B"
        default: rootNoteLetter = "Not Found"
        }
        counter += 1
        
        if individual {
            prompt = ""
            notes.removeAll()
            rootNote = UInt8(Int.random(in: 71...78)) //leave room for my vocal range
            notes.append(rootNote)
            switch rootNote % 12 {
            case 0: rootNoteLetter = "C"
            case 1: rootNoteLetter = "D♭"
            case 2: rootNoteLetter = "D"
            case 3: rootNoteLetter = "E♭"
            case 4: rootNoteLetter = "E"
            case 5: rootNoteLetter = "F"
            case 6: rootNoteLetter = "G♭"
            case 7: rootNoteLetter = "G"
            case 8: rootNoteLetter = "A♭"
            case 9: rootNoteLetter = "A"
            case 10: rootNoteLetter = "B♭"
            case 11: rootNoteLetter = "B"
            default: rootNoteLetter = "Not Found"
            }
            var done = false
            while !done { //have an audible range
                nextNote = UInt8(Int.random(in: 1...12))
                let coinflip = Int.random(in: 1...2)
                if coinflip == 1 { //descending
                    nextNote = rootNote - nextNote
                    if nextNote > 68 {
                        prompt += "Descending "
                        done = true
                    }
                } else { //ascending
                    nextNote = rootNote + nextNote
                    if nextNote <= 80 {
                        prompt += "Ascending "
                        done = true
                    }
                }
            }
            notes.append(nextNote)
            switch abs(Int(rootNote) - Int(nextNote)) {
            case 1: interval = "minor second"
            case 2: interval = "Major second"
            case 3: interval = "minor third"
            case 4: interval = "Major third"
            case 5: interval = "Perfect fourth"
            case 6: interval = "tritone"
            case 7: interval = "Perfect fifth"
            case 8: interval = "minor sixth"
            case 9: interval = "Major sixth"
            case 10: interval = "minor seventh"
            case 11: interval = "Major seventh"
            case 12: interval = "Perfect octave"
            default: interval = "not found"
            }
            prompt += interval
        }
        if individual {
            playRoot()
        } else {
            playSequence()
        }
    }
    
    func playSequence() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 0..<notes.count {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
    
    func playRoot() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 0...0 {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
    
    func playFirst() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 0...1 {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
    
    func playSecond() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 1...2 {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
    
    func playThird() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 2..<notes.count {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
}

#Preview {
    WhistleView()
}
