using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Rendering.PostProcessing;

//Needed to let unity serialize this and extend PostProcessEffectSettings
[Serializable]
//Using [PostProcess()] attrib allows us to tell Unity that the class holds postproccessing data. 
[PostProcess(renderer: typeof(CustomBloom),//First parameter links settings with actual renderer
            PostProcessEvent.AfterStack,//Tells Unity when to execute this postpro in the stack
            "Custom/Bloom")] //Creates a menu entry for the effect
                             //Forth parameter that allows to decide if the effect should be shown in scene view
public sealed class CustomBloomSettings : PostProcessEffectSettings
{
    [Range(0f, 1f), Tooltip("Blur Intensity.")]
    public FloatParameter blurIntensity = new FloatParameter { value = 0.1f }; //Custom parameter class, full list at: /PostProcessing/Runtime/
                                                                               //The default value is important, since is the one that will be used for blending if only 1 of volume has this effect
    [Range(10f, 100f), Tooltip("Blur Quantity.")]
    public FloatParameter steps = new FloatParameter { value = 50f };
}

public class CustomBloom : PostProcessEffectRenderer<CustomBloomSettings>//<T> is the setting type
{
    public override void Render(PostProcessRenderContext context)
    {
        //We get the actual shader property sheet
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Bloom"));
        //Set the uniform value for our shader
        sheet.properties.SetFloat("_intensity", settings.blurIntensity);
        sheet.properties.SetFloat("_quantity", settings.steps);

        //Temporal Texture
        var preTexture = RenderTexture.GetTemporary(context.width, context.height);
        var temporaryTexture = RenderTexture.GetTemporary(context.width, context.height);
        var bloomTex = RenderTexture.GetTemporary(context.width, context.height);
        var blurTexture = RenderTexture.GetTemporary(context.width, context.height);

        //We render the scene as a full screen triangle applying the specified shader

        //Take all pixels bright
        context.command.BlitFullscreenTriangle(context.source, preTexture, sheet, 3);

        sheet.properties.SetTexture("_temporalTex", preTexture);

        //Effect Saturate
        context.command.BlitFullscreenTriangle(context.source, temporaryTexture, sheet, 2);

        

        //Effect Blur
        context.command.BlitFullscreenTriangle(temporaryTexture,  blurTexture, sheet, 0);
        
        context.command.BlitFullscreenTriangle(blurTexture, bloomTex, sheet, 1);
        
        sheet.properties.SetTexture("_finalBloom", bloomTex);
        
        //Sum effect Bloom with normal texture
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 4);

        RenderTexture.ReleaseTemporary(preTexture);

        RenderTexture.ReleaseTemporary(blurTexture);
        
        RenderTexture.ReleaseTemporary(temporaryTexture);
        
        RenderTexture.ReleaseTemporary(bloomTex);
        
        //context.command.BlitFullscreenTriangle(blurTexture, context.destination, sheet, 2);
        //
        //blurTexture = RenderTexture.GetTemporary(context.width, context.height);
        //
        //context.command.BlitFullscreenTriangle(blurTexture, context.destination, sheet, 3);
        //
        //RenderTexture.ReleaseTemporary(blurTexture);
    }
}
