//
//  PhysicalValue.swift
//
//  Created by Jérôme Duquennoy on 08/01/2016.
//  Copyright © 2015 Jérôme Duquennoy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// A physical value is a floating point value associated to a unit.
public struct PhysicalValue {
  private let unit: MKSAUnit
  /// The value in the provided unit
  private let value: Double
  // The value normalized in the MKSA system
  // For exemple, if the physical value is 1km, value will be 1, and normalizedValue will be 1000
  internal var normalizedValue:Double { return unit.normalizedValue(value)}
  
  public init(value: Double, unit: MKSAUnit) {
    self.value = value;
    self.unit = unit;
  }

  public init(sourceValue: PhysicalValue) {
    self.init(value: sourceValue.value, unit: sourceValue.unit)
  }
}

// MARK: Operators & comparison

public func -(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue {
  // We cannot add values with different units.
  // But how to report that without crashing the app ?
  precondition(lhs.unit == rhs.unit, "Substracting values with different units is not a good idea, trust me.")
  return PhysicalValue(value: (lhs.normalizedValue - rhs.normalizedValue) / lhs.unit.scale, unit: lhs.unit)
}

public func +(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue {
  // We cannot add values with different units.
  // But how to report that without crashing the app ?
  precondition(lhs.unit == rhs.unit, "Adding values with different units is not a good idea, trust me.")
  return PhysicalValue(value: (lhs.normalizedValue + rhs.normalizedValue) / lhs.unit.scale - lhs.unit.unormalizedShift, unit: lhs.unit)
}

public func *(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue {
  let newUnit = lhs.unit * rhs.unit
  return PhysicalValue(value: newUnit.denormalizeValue(lhs.normalizedValue * rhs.normalizedValue), unit: newUnit)
}

public func /(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue {
  let newUnit = lhs.unit / rhs.unit
  return PhysicalValue(value: newUnit.denormalizeValue(lhs.normalizedValue / rhs.normalizedValue), unit: newUnit)
}

public func *(lhs: Double, rhs: PhysicalValue) -> PhysicalValue {
  return PhysicalValue(value: lhs * rhs.value, unit: rhs.unit)
}

public func /(lhs: Double, rhs: PhysicalValue) -> PhysicalValue {
  return PhysicalValue(value: lhs / rhs.value, unit: rhs.unit)
}

public func *(lhs: PhysicalValue, rhs: MKSAUnit) -> PhysicalValue {
  let normalizedValue = lhs.normalizedValue
  let newUnit = lhs.unit * rhs
  return PhysicalValue(value: newUnit.denormalizeValue(normalizedValue), unit: newUnit)
}

public func /(lhs: PhysicalValue, rhs: MKSAUnit) -> PhysicalValue {
  let normalizedValue = lhs.normalizedValue
  let newUnit = lhs.unit / rhs
  return PhysicalValue(value: newUnit.denormalizeValue(normalizedValue), unit: newUnit)
}

infix operator ** { associativity none precedence 160 }
public func **(lhs: PhysicalValue, power: Int) -> PhysicalValue {
  let newUnit = lhs.unit**power
  return PhysicalValue(value: pow(lhs.value, Double(power)), unit: newUnit)
}

public func sqrt(value: PhysicalValue) -> PhysicalValue {
  let newUnit = MKSAUnit(m: value.unit.m / 2,
    k: value.unit.k / 2,
    s: value.unit.s / 2,
    a: value.unit.a / 2,
    t: value.unit.t / 2,
    i: value.unit.i / 2,
    n: value.unit.n / 2,
    scale: sqrt(value.unit.scale),
    unormalizedShift: sqrt(value.unit.unormalizedShift))
  return PhysicalValue(value: sqrt(value.value), unit: newUnit);
}

extension PhysicalValue : Comparable, Equatable {
}

public func <(lhs: PhysicalValue, rhs: PhysicalValue) -> Bool {
  return lhs.value < rhs.value;
}

public func <=(lhs: PhysicalValue, rhs: PhysicalValue) -> Bool {
  return lhs.value < rhs.value;
}

public func >=(lhs: PhysicalValue, rhs: PhysicalValue) -> Bool {
  return lhs.value < rhs.value;
}

public func >(lhs: PhysicalValue, rhs: PhysicalValue) -> Bool {
  return lhs.value < rhs.value;
}

public func ==(lhs: PhysicalValue, rhs: PhysicalValue) -> Bool {
  return lhs.normalizedValue == rhs.normalizedValue && lhs.unit == rhs.unit;
}

extension PhysicalValue : CustomStringConvertible {
  public var description: String {
    return "\(self.normalizedValue) \(unit)"
  }
}

// MARK: Hepers to create PhysicalValues

public func *(lhs: Double, rhs: MKSAUnit) -> PhysicalValue {
  return PhysicalValue(value: lhs, unit: rhs);
}

/// MARK: Length
public let mm  = MKSAUnit(m: 1, scale: 0.001)
public let cm  = MKSAUnit(m: 1, scale: 0.01)
public let m   = MKSAUnit(m: 1)
public let km  = MKSAUnit(m: 1, scale: 1000)
/// MARK: Masse
public let kg  = MKSAUnit(k: 1)
/// MARK: Time
public let sec = MKSAUnit(s: 1)
public let min = MKSAUnit(s: 60)
public let h   = MKSAUnit(s: 1, scale: 3600)
/// MARK: Temperatures
public let K   = MKSAUnit(t: 1)
public let C   = MKSAUnit(t: 1, unormalizedShift: 273.15)
public let F   = MKSAUnit(t: 1, scale: 5/9, unormalizedShift: 459.67)
