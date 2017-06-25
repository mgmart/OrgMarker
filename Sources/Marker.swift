//
//  Marker.swift
//  OrgMarker
//
//  Created by Xiaoxing Hu on 13/03/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation
import Dispatch

struct Context {
    let text: String
    var grammar: Grammar
    var threads: Int
    
    init(_ _text: String,
         with _grammar: Grammar = Grammar.main(),
         threads _threads: Int = 4) {
        text = _text
        grammar = _grammar
        threads = _threads
    }
}

public struct Marker {
    
    let todos: [[String]]
    public var threads: Int = 4
    
    public init(
        todos _todos: [[String]] = [["TODO"], ["DONE"]]) {
        todos = _todos
    }
        
    public func mark(
        _ text: String,
        range: Range<String.Index>? = nil,
        parallel: Bool = false) -> OMResult<[Mark]> {
        let range = range ?? text.startIndex..<text.endIndex
        let parseF = parallel ? parallelParse : singalTheadedParse
        let f = buildContext |> updateGrammar |> curry(breakdown)(range) |> parseF
        return f(text)
    }
    
    private func buildContext(_ text: String) -> Result<Context> {
        let grammar = Grammar.main(todo: todos.flatMap { $0 })
        return .success(Context(text, with: grammar, threads: threads))
    }
}
