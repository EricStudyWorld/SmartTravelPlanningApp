//
//  TextResult.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import Foundation

class TextResult: Identifiable {
    var text: String = ""
}


class RecognizedContent: ObservableObject {
    @Published var result = TextResult()
}
