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

// MARK: - MKSAUnit

/// This class represents a unit in the MKSA system (meter, kilogram, second, amper)
public struct MKSAUnit : CustomStringConvertible {
  public let m: Int
  public let k: Int
  public let s: Int
  public let a: Int
  public let scale: Double
  
  public init(m: Int = 0, k: Int = 0, s: Int = 0, a: Int = 0, scale: Double = 1.0) {
    self.m = m
    self.k = k
    self.s = s
    self.a = a
    self.scale = scale
  }
  
  public var description: String {
    let unitToStingTransformer: (String, Int) -> String = { (name, value) in
      switch value {
      case 1, -1:
        return name
      case _ where abs(value) > 1:
        return "\(name)^\(value)"
      default:
        return ""
      }
    }
    let invertedUnitToStingTransformer: (String, Int) -> String = { (name, value) in
      switch value {
      case 1, -1:
        return name
      case _ where abs(value) > 1:
        return "\(name)^\(-value)"
      default:
        return ""
      }
    }
    
    let units = [("m", self.m), ("kg", self.k), ("s", self.s), ("A", self.a)]
    let positiveUnits = units.filter { $0.1 > 0 }.sort { $0.0.1 <= $0.1.1 }
    let negativeUnits = units.filter { $0.1 < 0 }.sort { $0.0.1 <= $0.1.1 }
    
    switch (positiveUnits.count, negativeUnits.count) {
    case let (positive, negative) where positive == 0 && negative == 0:
      return ""
    case let (positive, negative) where positive > 0 && negative == 0:
      return positiveUnits.map(unitToStingTransformer).joinWithSeparator(".")
    case let (positive, negative) where positive == 0 && negative > 0:
      return negativeUnits.map(unitToStingTransformer).joinWithSeparator(".")
    case let (positive, negative) where positive > 0 && negative > 0:
      return positiveUnits.map(unitToStingTransformer).joinWithSeparator(".") + "/" + negativeUnits.map(invertedUnitToStingTransformer).joinWithSeparator("/")
    default:
      return "Formatting error"
    }
  }
}

extension MKSAUnit : Equatable {
}
public func ==(lhs: MKSAUnit, rhs: MKSAUnit) -> Bool {
  return lhs.m == rhs.m
    && lhs.k == rhs.k
    && lhs.s == rhs.s
    && lhs.a == rhs.a
}

// MARK: - Physical unit

/// A physical value is a floating point value associated to a unit.
public struct PhysicalValue {
  private let unit: MKSAUnit
  private let value: Double
  /// Scaled value is the value with the unit scale factor applied to it.
  /// i.e., for a physical value declared as 1 km, the value will be 1000 (in the MKSA system, thus expressed in meters), the scaled value will be 1.
  internal var scaledValue:Double { return value * unit.scale }
  
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
  return PhysicalValue(value: (lhs.scaledValue - rhs.scaledValue) / lhs.unit.scale, unit: lhs.unit)
}
public func +(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue {
  // We cannot add values with different units.
  // But how to report that without crashing the app ?
  precondition(lhs.unit == rhs.unit, "Adding values with different units is not a good idea, trust me.")
  return PhysicalValue(value: (lhs.scaledValue + rhs.scaledValue) / lhs.unit.scale, unit: lhs.unit)
}
public func *(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue {
  let newUnit = MKSAUnit(m: lhs.unit.m + rhs.unit.m, k: lhs.unit.k + rhs.unit.k, s: lhs.unit.s + rhs.unit.s, a: lhs.unit.a + rhs.unit.a, scale: lhs.unit.scale)
  return PhysicalValue(value: (lhs.scaledValue * rhs.scaledValue) / lhs.unit.scale, unit: newUnit)
}
public func /(lhs: PhysicalValue, rhs: PhysicalValue) -> PhysicalValue {
  let newUnit = MKSAUnit(m: lhs.unit.m - rhs.unit.m, k: lhs.unit.k - rhs.unit.k, s: lhs.unit.s - rhs.unit.s, a: lhs.unit.a - rhs.unit.a, scale: lhs.unit.scale)
  return PhysicalValue(value: (lhs.scaledValue / rhs.scaledValue) / lhs.unit.scale, unit: newUnit)
}
infix operator ** { associativity none precedence 160 }
public func **(lhs: PhysicalValue, power: Int) -> PhysicalValue {
  let newUnit = MKSAUnit(m: lhs.unit.m * power, k: lhs.unit.k * power, s: lhs.unit.s * power, a: lhs.unit.a * power, scale: lhs.unit.scale)
  return PhysicalValue(value: pow(lhs.scaledValue, Double(power)), unit: newUnit)
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
  return lhs.scaledValue == rhs.scaledValue && lhs.unit == rhs.unit;
}

// MARK: Some other handy protocols conformance

extension PhysicalValue : FloatLiteralConvertible, IntegerLiteralConvertible, SignedNumberType {
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    
    public init(integerLiteral value: IntegerLiteralType) {
      self.value = Double(value)
      self.unit = MKSAUnit()
    }
    
    public init(floatLiteral value: FloatLiteralType) {
      self.value = value
      self.unit = MKSAUnit()
    }
}

extension PhysicalValue : Strideable {
  public func distanceTo(other: PhysicalValue) -> PhysicalValue {
    return PhysicalValue(value: self.value.distanceTo(other.value), unit: self.unit)
  }
  
  public func advancedBy(amount: PhysicalValue) -> PhysicalValue {
    return self + amount
  }
}

extension PhysicalValue : CustomStringConvertible {
  public var description: String {
    return "\(self.value * self.unit.scale) \(unit)"
  }
}

// MARK: - Some pre-defined units

public let mm  = PhysicalValue(value: 1, unit: MKSAUnit(m: 1, scale: 0.001))
public let cm  = PhysicalValue(value: 1, unit: MKSAUnit(m: 1, scale: 0.01))
public let m   = PhysicalValue(value: 1, unit: MKSAUnit(m: 1))
public let km  = PhysicalValue(value: 1, unit: MKSAUnit(m: 1, scale: 1000))
public let kg  = PhysicalValue(value: 1, unit: MKSAUnit(k: 1))
public let sec = PhysicalValue(value: 1, unit: MKSAUnit(s: 1))
public let min = PhysicalValue(value: 1, unit: MKSAUnit(s: 60))
public let h   = PhysicalValue(value: 1, unit: MKSAUnit(s: 1, scale: 3600))
