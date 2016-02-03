//
//  SwiftPhysicalValues
//
//  Created by Jérôme Duquennoy on 08/01/2016.
//  Copyright © 2015 Jérôme Duquennoy. All rights reserved.
//
// Having fun with physical values.
//
// This workspace demonstrates a way to play with physical values using swift.
// It includes :
// - some pre-defined units
// - ability to perform mathematical operations, that will provide a result with a unit
// - inability to perform invalid operations like adding values with different units
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

import Cocoa

// How long does it take to go from Paris to Bordeaux in a TGV running at 300km/h ?
let distance = 589 * km
let speed = 300 * (km / h)

distance / speed

// How fast will an object be after a 15 sec free fall with no initial speed ?
let g = 9.80665 * m / sec**2
var elapsedTime = 15 * sec
let finalSpeed = g * elapsedTime

// and how far will it be after 47 seconds ?
elapsedTime = 47 * sec
0.5 * g * elapsedTime**2

let temperature = 2 * C

// Do not add values with different units : it makes no sense !
elapsedTime + finalSpeed
