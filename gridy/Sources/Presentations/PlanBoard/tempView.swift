//
//  tempView.swift
//  gridy
//
//  Created by SY AN on 11/3/23.
//

import SwiftUI
import ComposableArchitecture

struct TempView: View {
    let store = Store(initialState: PlanBoard.State(
        rootProject: Project(id: "project1", title: "", ownerUid: "", createdDate: Date(), lastModifiedDate: Date(), rootPlanID: ""),
        rootPlan: Plan(id: "0000", planTypeID: "0000", childPlanIDs: [:]),
        map: [[]])) {
        PlanBoard()
    }
    
    @State var createLayer = "0"
    @State var createRow = "0"
    @State var createText = ""
    
    @State var updateLayer = "0"
    @State var updateRow = "0"
    @State var updateText = ""
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    VStack {
                        Text("Create Plan At")
                        HStack {
                            Text("Layer:")
                                TextField("", text: $createLayer)
                            
                            Text("Row:")
                                TextField("", text: $createRow)
                            
                            Text("Text:")
                                TextField("", text: $createText)
                        }
                        Button {
                            viewStore.send(
                                .createPlanOnList(layer: Int(createLayer)!, row: Int(createRow)!, text: createText)
                            )
                            createLayer = "0"
                            createRow = "0"
                            createText = ""
                        } label: {
                            Text("Create")
                        }
                    }
                    .padding()
                    .frame(width: 300)
                    
                    VStack {
                        Text("Update Plan At")
                        HStack {
                            Text("Layer:")
                                TextField("", text: $updateLayer)
                            
                            Text("Row:")
                                TextField("", text: $updateRow)
                            
                            Text("Text:")
                                TextField("", text: $updateText)
                        }
                        Button {
                            viewStore.send(
                                .updatePlanType(layer: Int(updateLayer)!, row: Int(updateRow)!, text: updateText, colorCode: PlanType.emptyPlanType.colorCode)
                            )
                            
                            updateLayer = "0"
                            updateRow = "0"
                            updateText = ""
                        } label: {
                            Text("Update")
                        }
                    }
                    .frame(width: 300)
                    .padding()
                }
                .padding(.vertical)
                
                Divider()
                
                HStack {
                    ForEach(0..<viewStore.map.count, id: \.self) { layerIndex in
                        VStack {
                            HStack {
                                Button {
                                    viewStore.send(
                                        .createLayerBtnClicked(layer: 0)
                                    )
                                } label: {
                                    Text("+")
                                }
                                
                                Text("layer \(layerIndex)")
                                
                                Button {
                                    viewStore.send(
                                        .createLayerBtnClicked(layer: 1)
                                    )
                                    print(viewStore.map)
                                } label: {
                                    Text("+")
                                }
                            }
                            ForEach(0..<viewStore.map[layerIndex].count, id: \.self) { rowIndex in
                                let planID = viewStore.map[layerIndex][rowIndex]
                                let plan = viewStore.existingAllPlans[planID]!
                                let planTypeID = plan.planTypeID
                                let planType = viewStore.existingPlanTypes[planTypeID]!
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(.blue)
                                    
                                    Text(planType.title)
                                }
                                .frame(width: 300, height: 20)
                                .padding(4)
                            }
                        }
                    }
                }
                .padding(.vertical)
                Spacer()
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
