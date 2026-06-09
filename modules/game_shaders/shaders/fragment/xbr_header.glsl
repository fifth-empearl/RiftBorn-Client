uniform sampler2D u_Tex0;
uniform float u_XbrEnabled;
uniform vec2 u_TextureSize;
varying vec2 v_TexCoord;

float xbrReduce(vec3 color) { return dot(color, vec3(65536.0, 256.0, 1.0)); }
float xbrDist(vec3 pixA, vec3 pixB) {
    const vec3 w = vec3(0.2627, 0.6780, 0.0593);
    const float scaleB = 0.5 / (1.0 - w.b);
    const float scaleR = 0.5 / (1.0 - w.r);
    vec3 diff = pixA - pixB;
    float Y = dot(diff, w);
    float Cb = scaleB * (diff.b - Y);
    float Cr = scaleR * (diff.r - Y);
    return sqrt(Y * Y + Cb * Cb + Cr * Cr);
}
bool xbrEq(vec3 pixA, vec3 pixB) { return xbrDist(pixA, pixB) < 15.0/255.0; }

vec4 xbrSampleAt(vec2 uv) {
    vec2 ps = 1.0 / u_TextureSize;
    float dx = ps.x, dy = ps.y;
    vec2 f = fract(uv * u_TextureSize);
    vec3 src[25];
    src[6]=texture2D(u_Tex0,uv+vec2(-dx,-dy)).rgb;
    src[7]=texture2D(u_Tex0,uv+vec2(0,-dy)).rgb;
    src[8]=texture2D(u_Tex0,uv+vec2(dx,-dy)).rgb;
    src[5]=texture2D(u_Tex0,uv+vec2(-dx,0)).rgb;
    src[0]=texture2D(u_Tex0,uv).rgb;
    src[1]=texture2D(u_Tex0,uv+vec2(dx,0)).rgb;
    src[4]=texture2D(u_Tex0,uv+vec2(-dx,dy)).rgb;
    src[3]=texture2D(u_Tex0,uv+vec2(0,dy)).rgb;
    src[2]=texture2D(u_Tex0,uv+vec2(dx,dy)).rgb;
    src[21]=src[6];src[22]=src[7];src[23]=src[8];
    src[15]=src[4];src[14]=src[3];src[13]=src[2];
    src[19]=src[6];src[18]=src[5];src[17]=src[4];
    src[9]=src[8];src[10]=src[1];src[11]=src[2];
    float v[9];
    v[0]=xbrReduce(src[0]);v[1]=xbrReduce(src[1]);v[2]=xbrReduce(src[2]);
    v[3]=xbrReduce(src[3]);v[4]=xbrReduce(src[4]);v[5]=xbrReduce(src[5]);
    v[6]=xbrReduce(src[6]);v[7]=xbrReduce(src[7]);v[8]=xbrReduce(src[8]);
    ivec4 blendResult = ivec4(0);
    if(((v[0]==v[1]&&v[3]==v[2])||(v[0]==v[3]&&v[1]==v[2]))==false){float d1=xbrDist(src[4],src[0])+xbrDist(src[0],src[8])+xbrDist(src[14],src[2])+xbrDist(src[2],src[10])+(4.0*xbrDist(src[3],src[1]));float d2=xbrDist(src[5],src[3])+xbrDist(src[3],src[13])+xbrDist(src[7],src[1])+xbrDist(src[1],src[11])+(4.0*xbrDist(src[0],src[2]));bool dom=(3.6*d1)<d2;blendResult[2]=((d1<d2)&&(v[0]!=v[1])&&(v[0]!=v[3]))?((dom)?2:1):0;}
    if(((v[5]==v[0]&&v[4]==v[3])||(v[5]==v[4]&&v[0]==v[3]))==false){float d1=xbrDist(src[17],src[5])+xbrDist(src[5],src[7])+xbrDist(src[15],src[3])+xbrDist(src[3],src[1])+(4.0*xbrDist(src[4],src[0]));float d2=xbrDist(src[18],src[4])+xbrDist(src[4],src[14])+xbrDist(src[6],src[0])+xbrDist(src[0],src[2])+(4.0*xbrDist(src[5],src[3]));bool dom=(3.6*d2)<d1;blendResult[3]=((d1>d2)&&(v[0]!=v[5])&&(v[0]!=v[3]))?((dom)?2:1):0;}
    if(((v[7]==v[8]&&v[0]==v[1])||(v[7]==v[0]&&v[8]==v[1]))==false){float d1=xbrDist(src[5],src[7])+xbrDist(src[7],src[23])+xbrDist(src[3],src[1])+xbrDist(src[1],src[9])+(4.0*xbrDist(src[0],src[8]));float d2=xbrDist(src[6],src[0])+xbrDist(src[0],src[2])+xbrDist(src[22],src[8])+xbrDist(src[8],src[10])+(4.0*xbrDist(src[7],src[1]));bool dom=(3.6*d2)<d1;blendResult[1]=((d1>d2)&&(v[0]!=v[7])&&(v[0]!=v[1]))?((dom)?2:1):0;}
    if(((v[6]==v[7]&&v[5]==v[0])||(v[6]==v[5]&&v[7]==v[0]))==false){float d1=xbrDist(src[18],src[6])+xbrDist(src[6],src[22])+xbrDist(src[4],src[0])+xbrDist(src[0],src[8])+(4.0*xbrDist(src[5],src[7]));float d2=xbrDist(src[19],src[5])+xbrDist(src[5],src[3])+xbrDist(src[21],src[7])+xbrDist(src[7],src[1])+(4.0*xbrDist(src[6],src[0]));bool dom=(3.6*d1)<d2;blendResult[0]=((d1<d2)&&(v[0]!=v[5])&&(v[0]!=v[7]))?((dom)?2:1):0;}
    vec3 dst[16];
    for(int i=0;i<16;i++) dst[i]=src[0];
    if(blendResult[0]!=0||blendResult[1]!=0||blendResult[2]!=0||blendResult[3]!=0){
        float dist_01_04=xbrDist(src[1],src[4]);float dist_03_08=xbrDist(src[3],src[8]);
        bool haveShallowLine=(2.2*dist_01_04<=dist_03_08)&&(v[0]!=v[4])&&(v[5]!=v[4]);
        bool haveSteepLine=(2.2*dist_03_08<=dist_01_04)&&(v[0]!=v[8])&&(v[7]!=v[8]);
        bool needBlend=(blendResult[2]!=0);
        bool doLineBlend=(blendResult[2]>=2||((blendResult[1]!=0&&!xbrEq(src[0],src[4]))||(blendResult[3]!=0&&!xbrEq(src[0],src[8]))||(xbrEq(src[4],src[3])&&xbrEq(src[3],src[2])&&xbrEq(src[2],src[1])&&xbrEq(src[1],src[8])&&xbrEq(src[0],src[2])==false))==false);
        vec3 blendPix=(xbrDist(src[0],src[1])<=xbrDist(src[0],src[3]))?src[1]:src[3];
        dst[2]=mix(dst[2],blendPix,(needBlend&&doLineBlend)?((haveShallowLine)?((haveSteepLine)?1.0/3.0:0.25):((haveSteepLine)?0.25:0.0)):0.0);
        dst[9]=mix(dst[9],blendPix,(needBlend&&doLineBlend&&haveSteepLine)?0.25:0.0);
        dst[10]=mix(dst[10],blendPix,(needBlend&&doLineBlend&&haveSteepLine)?0.75:0.0);
        dst[11]=mix(dst[11],blendPix,(needBlend)?((doLineBlend)?((haveSteepLine)?1.0:((haveShallowLine)?0.75:0.50)):0.08677704501):0.0);
        dst[12]=mix(dst[12],blendPix,(needBlend)?((doLineBlend)?1.0:0.6848532563):0.0);
        dst[13]=mix(dst[13],blendPix,(needBlend)?((doLineBlend)?((haveShallowLine)?1.0:((haveSteepLine)?0.75:0.50)):0.08677704501):0.0);
        dst[14]=mix(dst[14],blendPix,(needBlend&&doLineBlend&&haveShallowLine)?0.75:0.0);
        dst[15]=mix(dst[15],blendPix,(needBlend&&doLineBlend&&haveShallowLine)?0.25:0.0);
        dist_01_04=xbrDist(src[7],src[2]);dist_03_08=xbrDist(src[1],src[6]);
        haveShallowLine=(2.2*dist_01_04<=dist_03_08)&&(v[0]!=v[2])&&(v[3]!=v[2]);
        haveSteepLine=(2.2*dist_03_08<=dist_01_04)&&(v[0]!=v[6])&&(v[5]!=v[6]);
        needBlend=(blendResult[1]!=0);
        doLineBlend=(blendResult[1]>=2||!((blendResult[0]!=0&&!xbrEq(src[0],src[2]))||(blendResult[2]!=0&&!xbrEq(src[0],src[6]))||(xbrEq(src[2],src[1])&&xbrEq(src[1],src[8])&&xbrEq(src[8],src[7])&&xbrEq(src[7],src[6])&&!xbrEq(src[0],src[8]))));
        blendPix=(xbrDist(src[0],src[7])<=xbrDist(src[0],src[1]))?src[7]:src[1];
        dst[1]=mix(dst[1],blendPix,(needBlend&&doLineBlend)?((haveShallowLine)?((haveSteepLine)?1.0/3.0:0.25):((haveSteepLine)?0.25:0.0)):0.0);
        dst[6]=mix(dst[6],blendPix,(needBlend&&doLineBlend&&haveSteepLine)?0.25:0.0);
        dst[7]=mix(dst[7],blendPix,(needBlend&&doLineBlend&&haveSteepLine)?0.75:0.0);
        dst[8]=mix(dst[8],blendPix,(needBlend)?((doLineBlend)?((haveSteepLine)?1.0:((haveShallowLine)?0.75:0.50)):0.08677704501):0.0);
        dst[9]=mix(dst[9],blendPix,(needBlend)?((doLineBlend)?1.0:0.6848532563):0.0);
        dst[10]=mix(dst[10],blendPix,(needBlend)?((doLineBlend)?((haveShallowLine)?1.0:((haveSteepLine)?0.75:0.50)):0.08677704501):0.0);
        dst[11]=mix(dst[11],blendPix,(needBlend&&doLineBlend&&haveShallowLine)?0.75:0.0);
        dst[12]=mix(dst[12],blendPix,(needBlend&&doLineBlend&&haveShallowLine)?0.25:0.0);
        dist_01_04=xbrDist(src[5],src[8]);dist_03_08=xbrDist(src[7],src[4]);
        haveShallowLine=(2.2*dist_01_04<=dist_03_08)&&(v[0]!=v[8])&&(v[1]!=v[8]);
        haveSteepLine=(2.2*dist_03_08<=dist_01_04)&&(v[0]!=v[4])&&(v[3]!=v[4]);
        needBlend=(blendResult[0]!=0);
        doLineBlend=(blendResult[0]>=2||!((blendResult[3]!=0&&!xbrEq(src[0],src[8]))||(blendResult[1]!=0&&!xbrEq(src[0],src[4]))||(xbrEq(src[8],src[7])&&xbrEq(src[7],src[6])&&xbrEq(src[6],src[5])&&xbrEq(src[5],src[4])&&!xbrEq(src[0],src[6]))));
        blendPix=(xbrDist(src[0],src[5])<=xbrDist(src[0],src[7]))?src[5]:src[7];
        dst[0]=mix(dst[0],blendPix,(needBlend&&doLineBlend)?((haveShallowLine)?((haveSteepLine)?1.0/3.0:0.25):((haveSteepLine)?0.25:0.0)):0.0);
        dst[15]=mix(dst[15],blendPix,(needBlend&&doLineBlend&&haveSteepLine)?0.25:0.0);
        dst[4]=mix(dst[4],blendPix,(needBlend&&doLineBlend&&haveSteepLine)?0.75:0.0);
        dst[5]=mix(dst[5],blendPix,(needBlend)?((doLineBlend)?((haveSteepLine)?1.0:((haveShallowLine)?0.75:0.50)):0.08677704501):0.0);
        dst[6]=mix(dst[6],blendPix,(needBlend)?((doLineBlend)?1.0:0.6848532563):0.0);
        dst[7]=mix(dst[7],blendPix,(needBlend)?((doLineBlend)?((haveShallowLine)?1.0:((haveSteepLine)?0.75:0.50)):0.08677704501):0.0);
        dst[8]=mix(dst[8],blendPix,(needBlend&&doLineBlend&&haveShallowLine)?0.75:0.0);
        dst[9]=mix(dst[9],blendPix,(needBlend&&doLineBlend&&haveShallowLine)?0.25:0.0);
        dist_01_04=xbrDist(src[3],src[6]);dist_03_08=xbrDist(src[5],src[2]);
        haveShallowLine=(2.2*dist_01_04<=dist_03_08)&&(v[0]!=v[6])&&(v[7]!=v[6]);
        haveSteepLine=(2.2*dist_03_08<=dist_01_04)&&(v[0]!=v[2])&&(v[1]!=v[2]);
        needBlend=(blendResult[3]!=0);
        doLineBlend=(blendResult[3]>=2||!((blendResult[2]!=0&&!xbrEq(src[0],src[6]))||(blendResult[0]!=0&&!xbrEq(src[0],src[2]))||(xbrEq(src[6],src[5])&&xbrEq(src[5],src[4])&&xbrEq(src[4],src[3])&&xbrEq(src[3],src[2])&&!xbrEq(src[0],src[4]))));
        blendPix=(xbrDist(src[0],src[3])<=xbrDist(src[0],src[5]))?src[3]:src[5];
        dst[3]=mix(dst[3],blendPix,(needBlend&&doLineBlend)?((haveShallowLine)?((haveSteepLine)?1.0/3.0:0.25):((haveSteepLine)?0.25:0.0)):0.0);
        dst[12]=mix(dst[12],blendPix,(needBlend&&doLineBlend&&haveSteepLine)?0.25:0.0);
        dst[13]=mix(dst[13],blendPix,(needBlend&&doLineBlend&&haveSteepLine)?0.75:0.0);
        dst[14]=mix(dst[14],blendPix,(needBlend)?((doLineBlend)?((haveSteepLine)?1.0:((haveShallowLine)?0.75:0.50)):0.08677704501):0.0);
        dst[15]=mix(dst[15],blendPix,(needBlend)?((doLineBlend)?1.0:0.6848532563):0.0);
        dst[4]=mix(dst[4],blendPix,(needBlend)?((doLineBlend)?((haveShallowLine)?1.0:((haveSteepLine)?0.75:0.50)):0.08677704501):0.0);
        dst[5]=mix(dst[5],blendPix,(needBlend&&doLineBlend&&haveShallowLine)?0.75:0.0);
        dst[6]=mix(dst[6],blendPix,(needBlend&&doLineBlend&&haveShallowLine)?0.25:0.0);
    }
    vec3 res=mix(mix(mix(mix(dst[6],dst[7],step(0.25,f.x)),mix(dst[8],dst[9],step(0.75,f.x)),step(0.50,f.x)),mix(mix(dst[5],dst[0],step(0.25,f.x)),mix(dst[1],dst[10],step(0.75,f.x)),step(0.50,f.x)),step(0.25,f.y)),mix(mix(mix(dst[4],dst[3],step(0.25,f.x)),mix(dst[2],dst[11],step(0.75,f.x)),step(0.50,f.x)),mix(mix(dst[15],dst[14],step(0.25,f.x)),mix(dst[13],dst[12],step(0.75,f.x)),step(0.50,f.x)),step(0.75,f.y)),step(0.50,f.y));
    return vec4(res, 1.0);
}

vec4 mapSampleAt(vec2 uv) { return u_XbrEnabled > 0.5 ? xbrSampleAt(uv) : texture2D(u_Tex0, uv); }
vec4 xbrSample() { return xbrSampleAt(v_TexCoord); }
