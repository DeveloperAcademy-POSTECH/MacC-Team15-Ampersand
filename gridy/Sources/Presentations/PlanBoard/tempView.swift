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
    
    @State var createLayer = ""
    @State var createRow = ""
    @State var createText = ""
    
    @State var updateLayer = ""
    @State var updateRow = ""
    @State var updateText = ""
    
    @State var deleteLayer = ""
    @State var deleteRow = ""
    
    @State var laneRow = ""
    
    @State var fromRow = ""
    @State var toRow = ""
    
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
                            TextField("", text: $createRow)
                        }
                        Button {
                            viewStore.send(
                                .createPlanOnList(
                                    layer: Int(createLayer)!,
                                    row: Int(createRow)!,
                                    text: createRow,
                                    colorCode: nil
                                )
                            )
                            createLayer = ""
                            createRow = ""
                            createText = ""
                        } label: {
                            Text("Create")
                        }
                    }
                    .frame(width: 300)
                    .padding()
                    
                    VStack {
                        Text("Update Plan At")
                        HStack {
                            Text("Layer:")
                            TextField("", text: $updateLayer)
                            
                            Text("Row:")
                            TextField("", text: $updateRow)
                            
                            Text("Text:")
                            TextField("", text: $updateRow)
                        }
                        Button {
                            viewStore.send(
                                .updatePlanTypeOnList(
                                    targetPlanID: Plan.mock.id,
                                    text: updateRow,
                                    colorCode: PlanType.emptyPlanType.colorCode
                                )
                            )
                            
                            updateLayer = ""
                            updateRow = ""
                            updateText = ""
                        } label: {
                            Text("Update")
                        }
                    }
                    .frame(width: 300)
                    .padding()
                    
                    VStack {
                        Text("delete Plan At")
                        HStack {
                            Text("Layer:")
                            TextField("", text: $deleteLayer)
                            
                            Text("Row:")
                            TextField("", text: $deleteRow)
                        }
                        Button {
                            viewStore.send(
                                .deletePlanOnList(
                                    layer: Int(deleteLayer)!,
                                    row: Int(deleteRow)!
                                )
                            )
                        } label: {
                            Text("Delete")
                        }
                    }
                    .frame(width: 200)
                    .padding()
                    
                    //                    VStack {
                    //                        Text("create UpperLane At")
                    //                        HStack {
                    //                            Text("Row:")
                    //                                TextField("", text: $laneRow)
                    //                        }
                    //                        Button {
                    //                            viewStore.send(
                    //                                .createLaneButtonClicked(row: Int(laneRow)!, createOnTop: true)
                    //                            )
                    //                        } label: {
                    //                            Text("Create")
                    //                        }
                    //                    }
                    //                    .frame(width: 200)
                    //                    .padding()
                    //
                    //                    VStack {
                    //                        Text("create lowerLane At")
                    //                        HStack {
                    //                            Text("Row:")
                    //                                TextField("", text: $laneRow)
                    //                        }
                    //                        Button {
                    //                            viewStore.send(
                    //                                .createLaneButtonClicked(row: Int(laneRow)!, createOnTop: false)
                    //                            )
                    //                        } label: {
                    //                            Text("Create")
                    //                        }
                    //                    }
                    //                    .frame(width: 200)
                    //                    .padding()
                    
                    VStack {
                        Text("deleteLane")
                        HStack {
                            Text("from:")
                            TextField("", text: $fromRow)
                            
                            Text("to:")
                            TextField("", text: $toRow)
                        }

                        Button {
                            viewStore.send(
                                .deleteLaneConents(rows: [Int(fromRow)!, Int(toRow)!])
                            )
                        } label: {
                            Text("Create")
                        }
                    }
                    .frame(width: 200)
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
                                        .createLayerButtonClicked(layer: 0)
                                    )
                                } label: {
                                    Text("+")
                                }
                                
                                Text("layer \(layerIndex)")
                                    .contextMenu {
                                        if viewStore.map.count != 1 {
                                            Button {
                                                viewStore.send(
                                                    .deleteLayer(layer: layerIndex)
                                                )
                                            } label: {
                                                Text("이 레이어 삭제")
                                            }
                                        }
                                        
                                        Button {
                                            viewStore.send(
                                                .deleteLayerContents(layer: layerIndex)
                                            )
                                        } label: {
                                            Text("이 레이어 글자만 삭제")
                                        }
                                    }
                                
                                Button {
                                    viewStore.send(
                                        .createLayerBtnClicked(layer: 1)
                                    )
                                    print(viewStore.map)
                                } label: {
                                    Text("+")
                                }
                            }
                            .frame(width: 300, height: 20)
                        }
                    }
                }
                ScrollView {
                    HStack {
                        ForEach(0..<viewStore.map.count, id: \.self) { layerIndex in
                            VStack {
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
                                    .frame(width: 300, height: CGFloat(plan.childPlanIDs.count) * 20)
                                    .padding(4)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    Spacer()
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
