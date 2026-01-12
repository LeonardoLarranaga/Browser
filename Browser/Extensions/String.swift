//
//  String.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 11/1/26.
//

extension String {
  var isReallyEmpty: Bool {
    self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}
