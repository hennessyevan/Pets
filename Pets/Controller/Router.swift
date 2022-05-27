import Foundation
import Helm

typealias RouteSegue = Segue<RoutesFragment>
typealias RouteGraph = Set<RouteSegue>
typealias RouteEdge = DirectedEdge<RoutesFragment>


enum RoutesFragment: Fragment {
  case pets
  case pet
}

let segues: RouteGraph = [
  RouteSegue(.pets => .pet).makeDismissable()
]
