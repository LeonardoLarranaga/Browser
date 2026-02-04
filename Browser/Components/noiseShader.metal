//
//  noiseShader.metal
//  Browser
//
//  Created by Leonardo Larrañaga on 2/11/25.
//

#include <metal_stdlib>
using namespace metal;

float hash(float2 p) {
    float3 p3 = fract(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

[[ stitchable ]]
half4 noiseShader(float2 position, half4 color, float2 size, float time) {
    float noise = hash(position);
    return half4(half3(noise), color.a);
}
