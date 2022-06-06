using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Rendering.PostProcessing;

//Needed to let unity serialize this and extend PostProcessEffectSettings
[Serializable]
//Using [PostProcess()] attrib allows us to tell Unity that the class holds postproccessing data. 
[PostProcess(renderer: typeof(CustomPostproVignette),//First parameter links settings with actual renderer
            PostProcessEvent.AfterStack,//Tells Unity when to execute this postpro in the stack
            "Custom/Vignette")] //Creates a menu entry for the effect
                                    //Forth parameter that allows to decide if the effect should be shown in scene view
public sealed class CustomPostproVignetteSettings : PostProcessEffectSettings
{
    [Range(0f, 10f), Tooltip("Position.")]
    public Vector2Parameter framePos = new Vector2Parameter { value = new Vector2(1.0f,1.0f) };
    
    [Range(0.1f, 50f), Tooltip("Size.")]
    public FloatParameter size = new FloatParameter { value = 0.5f }; //Custom parameter class, full list at: /PostProcessing/Runtime/
                                                                      //The default value is important, since is the one that will be used for blending if only 1 of volume has this effect

    [Range(2f, 200f), Tooltip("Falloff.")]
    public FloatParameter falloff = new FloatParameter { value = 2f };

    [Tooltip("Screen Color.")]
    public ColorParameter screenColor = new ColorParameter { value = Color.white };
}

public class CustomPostproVignette : PostProcessEffectRenderer<CustomPostproVignetteSettings>//<T> is the setting type
{
    public override void Render(PostProcessRenderContext context)
    {
        //We get the actual shader property sheet
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/Vignette"));

        //Set the uniform value for our shader
        sheet.properties.SetFloat("_size", settings.size);
        sheet.properties.SetVector("_framePos", settings.framePos);
        sheet.properties.SetFloat("_falloff", settings.falloff);
        sheet.properties.SetColor("_screenColor", settings.screenColor);

        //We render the scene as a full screen triangle applying the specified shader
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}