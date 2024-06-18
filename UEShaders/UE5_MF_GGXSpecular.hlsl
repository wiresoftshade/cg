/* Custom node text for copy-paste
  
Begin Object Class=/Script/UnrealEd.MaterialGraphNode Name="MaterialGraphNode_1" ExportPath="/Script/UnrealEd.MaterialGraphNode'/Engine/Transient.Material_0:MaterialGraph_0.MaterialGraphNode_1'"
   Begin Object Class=/Script/Engine.MaterialExpressionCustom Name="MaterialExpressionCustom_0" ExportPath="/Script/Engine.MaterialExpressionCustom'/Engine/Transient.Material_0:MaterialGraph_0.MaterialGraphNode_1.MaterialExpressionCustom_0'"
   End Object
   Begin Object Name="MaterialExpressionCustom_0" ExportPath="/Script/Engine.MaterialExpressionCustom'/Engine/Transient.Material_0:MaterialGraph_0.MaterialGraphNode_1.MaterialExpressionCustom_0'"
      Code="\t\t\tfloat NoH = dot( normalize(Normal + LightVector), Normal);\r\n\t\r\n\t\t\tfloat a2 = Pow4( Roughness );\r\n\t\t\tfloat d = ( NoH * a2 - NoH ) * NoH + 1;\t// 2 mad\r\n\t\t\treturn a2 / ( PI*d*d );\t\t\t\t\t// 4 mul, 1 rcp"
      OutputType=CMOT_Float1
      Inputs(0)=(InputName="Normal",Input=(Expression="/Script/Engine.MaterialExpressionFunctionInput'/Engine/Transient.GGXSpecular:MaterialExpressionFunctionInput_0'"))
      Inputs(1)=(InputName="LightVector",Input=(Expression="/Script/Engine.MaterialExpressionFunctionInput'/Engine/Transient.GGXSpecular:MaterialExpressionFunctionInput_1'"))
      Inputs(2)=(InputName="Roughness",Input=(Expression="/Script/Engine.MaterialExpressionFunctionInput'/Engine/Transient.GGXSpecular:MaterialExpressionFunctionInput_2'"))
      MaterialExpressionEditorX=-384
      MaterialExpressionEditorY=368
      MaterialExpressionGuid=B4C1622F478A0D6EFEFF7C9E96C729DF
      Material="/Script/Engine.Material'/Engine/Transient.Material_0'"
   End Object
   MaterialExpression="/Script/Engine.MaterialExpressionCustom'MaterialExpressionCustom_0'"
   NodePosX=-384
   NodePosY=368
   NodeGuid=A86C4A34443C7DC49CA97F85DD91B20F
   CustomProperties Pin (PinId=4BAFFDCA4F4090B86AD12A94BA9FD12A,PinName="Normal",PinType.PinCategory="required",PinType.PinSubCategory="",PinType.PinSubCategoryObject=None,PinType.PinSubCategoryMemberReference=(),PinType.PinValueType=(),PinType.ContainerType=None,PinType.bIsReference=False,PinType.bIsConst=False,PinType.bIsWeakPointer=False,PinType.bIsUObjectWrapper=False,PinType.bSerializeAsSinglePrecisionFloat=False,LinkedTo=(MaterialGraphNode_2 29CE53A549C85BB8ECBAEA8DF7740434,),PersistentGuid=00000000000000000000000000000000,bHidden=False,bNotConnectable=False,bDefaultValueIsReadOnly=False,bDefaultValueIsIgnored=False,bAdvancedView=False,bOrphanedPin=False,)
   CustomProperties Pin (PinId=6290E314427ADDA41A55B6AEB16411ED,PinName="LightVector",PinType.PinCategory="required",PinType.PinSubCategory="",PinType.PinSubCategoryObject=None,PinType.PinSubCategoryMemberReference=(),PinType.PinValueType=(),PinType.ContainerType=None,PinType.bIsReference=False,PinType.bIsConst=False,PinType.bIsWeakPointer=False,PinType.bIsUObjectWrapper=False,PinType.bSerializeAsSinglePrecisionFloat=False,LinkedTo=(MaterialGraphNode_3 5C6DDE6B4B2E68169B0DB4862AF3DCD5,),PersistentGuid=00000000000000000000000000000000,bHidden=False,bNotConnectable=False,bDefaultValueIsReadOnly=False,bDefaultValueIsIgnored=False,bAdvancedView=False,bOrphanedPin=False,)
   CustomProperties Pin (PinId=19AC508244ACF57F59499483F9C4E16B,PinName="Roughness",PinType.PinCategory="required",PinType.PinSubCategory="",PinType.PinSubCategoryObject=None,PinType.PinSubCategoryMemberReference=(),PinType.PinValueType=(),PinType.ContainerType=None,PinType.bIsReference=False,PinType.bIsConst=False,PinType.bIsWeakPointer=False,PinType.bIsUObjectWrapper=False,PinType.bSerializeAsSinglePrecisionFloat=False,LinkedTo=(MaterialGraphNode_4 5FC8464B4B697E836F05AEA349031813,),PersistentGuid=00000000000000000000000000000000,bHidden=False,bNotConnectable=False,bDefaultValueIsReadOnly=False,bDefaultValueIsIgnored=False,bAdvancedView=False,bOrphanedPin=False,)
   CustomProperties Pin (PinId=D30515DB41C8FF33D2A6998D3343E69E,PinName="Output",PinFriendlyName=NSLOCTEXT("MaterialGraphNode", "Space", " "),Direction="EGPD_Output",PinType.PinCategory="",PinType.PinSubCategory="",PinType.PinSubCategoryObject=None,PinType.PinSubCategoryMemberReference=(),PinType.PinValueType=(),PinType.ContainerType=None,PinType.bIsReference=False,PinType.bIsConst=False,PinType.bIsWeakPointer=False,PinType.bIsUObjectWrapper=False,PinType.bSerializeAsSinglePrecisionFloat=False,LinkedTo=(MaterialGraphNode_0 520B73EB4B30DACB013357BA89A3E9DF,),PersistentGuid=00000000000000000000000000000000,bHidden=False,bNotConnectable=False,bDefaultValueIsReadOnly=False,bDefaultValueIsIgnored=False,bAdvancedView=False,bOrphanedPin=False,)
End Object


*/

// GGXSpecular material function in UE5
    //   InputName="Normal"
    //   Description="The surface normal."
    //   InputName="Light Vector"
    //   Description="The light vector to calculate specular for."
    //   InputName="Roughness"
    //   Description="The surface roughness"

float main(float3 Normal, float3 LightVector, float Roughness)
{
			float NoH = dot( normalize(Normal + LightVector), Normal);
	
			float a2 = Pow4( Roughness );
			float d = ( NoH * a2 - NoH ) * NoH + 1;	// 2 mad
			return a2 / ( PI*d*d );					// 4 mul, 1 rcp
}

