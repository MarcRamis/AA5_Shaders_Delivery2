using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Rendering.PostProcessing;

//Needed to let unity serialize this and extend PostProcessEffectSettings
[Serializable]
//Using [PostProcess()] attrib allows us to tell Unity that the class holds postproccessing data. 
[PostProcess(renderer: typeof(CustomBlur),//First parameter links settings with actual renderer
            PostProcessEvent.AfterStack,//Tells Unity when to execute this postpro in the stack
            "Custom/Blur")] //Creates a menu entry for the effect
                            //Forth parameter that allows to decide if the effect should be shown in scene view
public sealed class CustomBlurSettings : PostProcessEffectSettings
{
    [Range(0f, 1f), Tooltip("Blur Intensity.")]
    public FloatParameter blurIntensity = new FloatParameter { value = 0.1f }; //Custom parameter class, full list at: /PostProcessing/Runtime/
                                                                               //The default value is important, since is the one that will be used for blending if only 1 of volume has this effect
    [Range(10f, 100f), Tooltip("Blur Quantity.")]
    public FloatParameter steps = new FloatParameter { value = 50f };
}

public class CustomBlur : PostProcessEffectRenderer<CustomBlurSettings>//<T> is the setting type
{
    public override void Render(PostProcessRenderContext context)
    {
        //We get the actual shader property sheet
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Blur"));
        //Set the uniform value for our shader
        sheet.properties.SetFloat("_intensity", settings.blurIntensity);
        sheet.properties.SetFloat("_quantity", settings.steps);
        var temporaryTexture = RenderTexture.GetTemporary(context.width, context.height);
        //Temporal texture
        //UnityEngine.Rendering.Render tempTexture = context.source;
        //RenderTexture tempTexture = new RenderTexture().RenderTexture;
        //var sheet2 = tempTexture.propertySheets.Get(Shader.Find("Hidden/Custom/Blur"));
        ////Set the uniform value for our shader
        //sheet2.properties.SetFloat("_intensity", settings.blurIntensity);
        //sheet2.properties.SetFloat("_quantity", settings.steps);

        //We render the scene as a full screen triangle applying the specified shader
        context.command.BlitFullscreenTriangle(context.source, temporaryTexture, sheet, 0);
        context.command.BlitFullscreenTriangle(temporaryTexture, context.destination, sheet, 1);
        RenderTexture.ReleaseTemporary(temporaryTexture);
    }
}
