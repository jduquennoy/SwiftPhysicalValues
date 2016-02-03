//
//  MKSAUnit.swift
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

/// This class represents a unit in the MKSA system (meter, kilogram, second, amper)
/// The 7 available dimensions are :
/// - length (meters)
/// - weight (kilograms)
/// - time (seconds)
/// - intensité (ampers)
/// - temperature (kelvins)
/// - light intensity (candela)
/// - amount (mole)
public struct MKSAUnit : CustomStringConvertible {
  /// Length dimension (meters)
  public let m: Int
  /// Weight dimension (kilograms)
  public let k: Int
  /// Time dimension (seconds)
  public let s: Int
  /// Electric intensity dimension (ampers)
  public let a: Int
  /// Temperature dimension (kelvins)
  public let t: Int
  /// Light intensity dimension (candela)
  public let i: Int
  /// Amount dimension (mole)
  public let n: Int
  /// Scale between unit and reference unit
  public let scale: Double
  /// Shift between unit and reference unit, applied before applying the scale
  public let unormalizedShift: Double
  
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
    
    let units = [("m", self.m), ("kg", self.k), ("s", self.s), ("A", self.a), ("K", self.t), ("cd", self.i), ("mol", self.n)]
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
  
  public init(m: Int = 0, k: Int = 0, s: Int = 0, a: Int = 0, t: Int = 0, i: Int = 0, n: Int = 0, scale: Double = 1.0, unormalizedShift: Double = 0.0) {
    self.m = m
    self.k = k
    self.s = s
    self.a = a
    self.t = t
    self.i = i
    self.n = n
    self.scale = scale
    self.unormalizedShift = unormalizedShift
  }
  
  /// converts the given value from the current unit to MKSA
  internal func normalizedValue(value: Double) -> Double {
    return (value * self.scale) + self.unormalizedShift
  }
  
  // converts the given value from MKSA to the current unit
  internal func denormalizeValue(value: Double) -> Double {
    return (value - self.unormalizedShift) / scale
  }
}

extension MKSAUnit : Equatable {
}

/// Unit equality only test that the two units are in the same dimension (and are therefore compatible for addition and substraction operations)
public func ==(lhs: MKSAUnit, rhs: MKSAUnit) -> Bool {
  return lhs.m == rhs.m
    && lhs.k == rhs.k
    && lhs.s == rhs.s
    && lhs.a == rhs.a
    && lhs.t == rhs.t
    && lhs.i == rhs.i
    && lhs.n == rhs.n
}

infix operator ** { associativity none precedence 160 }
public func **(lhs: MKSAUnit, power: Int) -> MKSAUnit {
  return MKSAUnit(m: lhs.m * power,
    k: lhs.k * power,
    s: lhs.s * power,
    a: lhs.a * power,
    t: lhs.t * power,
    i: lhs.i * power,
    n: lhs.n * power,
    scale: pow(lhs.scale, Double(power)),
    unormalizedShift: pow(lhs.unormalizedShift, Double(power)))
}

public func *(lhs: MKSAUnit, rhs: MKSAUnit) -> MKSAUnit {
  return MKSAUnit(m: lhs.m + rhs.m,
    k: lhs.k + rhs.k,
    s: lhs.s + rhs.s,
    a: lhs.a + rhs.a,
    t: lhs.t + rhs.t,
    i: lhs.i + rhs.i,
    n: lhs.n + rhs.n,
    scale: lhs.scale * lhs.scale,
    unormalizedShift: lhs.unormalizedShift + lhs.unormalizedShift)
}

public func /(lhs: MKSAUnit, rhs: MKSAUnit) -> MKSAUnit {
  return MKSAUnit(m: lhs.m - rhs.m,
    k: lhs.k - rhs.k,
    s: lhs.s - rhs.s,
    a: lhs.a - rhs.a,
    t: lhs.t - rhs.t,
    i: lhs.i - rhs.i,
    n: lhs.n - rhs.n,
    scale: lhs.scale,
    unormalizedShift: lhs.unormalizedShift)
}
