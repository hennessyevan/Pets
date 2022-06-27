//
//  ButtonStyles.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-22.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import SwiftUI

struct ButtonStyles: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
			Button("Press me", action: {}).buttonStyle(.automatic)
    }
}
