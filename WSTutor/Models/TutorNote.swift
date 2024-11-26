//
//  TutorNote.swift
//  WSTutor
//
//  Created by Russell Kernaghan on 2024-11-25.
//
import Foundation

class TutorNote: Identifiable {
	
	var noteText: String
	let id = UUID()
	
	init(noteText: String) {
		self.noteText = noteText
	}
	
}
