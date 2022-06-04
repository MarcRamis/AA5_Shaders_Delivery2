using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Light : MonoBehaviour
{
    public enum LightType { Point, Directional, Spot };
    public LightType type;
    public Vector3 direction;
    public Color color;
    public float intensity;

    Material lightMat;
    public Material[] mats;

    // Start is called before the first frame update
    void OnEnable()
    {
        direction = transform.forward;
        //mat = ;
        if (type == LightType.Point)
        {
            Shader.EnableKeyword("POINT_LIGHT_ON");
            lightMat = GetComponent<Renderer>().sharedMaterial;
        }
        if (type == LightType.Directional)
        {
            Shader.EnableKeyword("DIRECTIONAL_LIGHT_ON");
        }
        if (type == LightType.Spot)
        {
            Shader.EnableKeyword("SPOT_LIGHT_ON");
        }
            

    }
    private void OnDisable()
    {
        if (type == LightType.Point)
        {
            Shader.DisableKeyword("POINT_LIGHT_ON");
        }
        if (type == LightType.Directional)
        {
            Shader.DisableKeyword("DIRECTIONAL_LIGHT_ON");
        }
        if (type == LightType.Spot)
        { 
            Shader.DisableKeyword("SPOT_LIGHT_ON");
        }
    }
    private void OnDrawGizmos()
    {
        if (type == LightType.Directional)
            Debug.DrawLine(transform.position, transform.position + direction, color);
        if (type == LightType.Spot)
        {
            Debug.DrawLine(transform.position, transform.position + direction * 2, color);
        }
    }

    // Update is called once per frame
    void Update()
    {
        foreach (Material mat in mats)
        {
            if (type == LightType.Directional)
            {
                direction = transform.forward;
                mat.SetVector("_directionalLightDir", -direction);
                mat.SetColor("_directionalLightColor", color);
            }
            else if (type == LightType.Point)
            {
                mat.SetVector("_pointLightPos", transform.position);
                mat.SetColor("_pointLightColor", color);
                //lightMat.SetColor("_EmissionColor", color * 20 * intensity);
            }
            else if (type == LightType.Spot)
            {
                mat.SetVector("_spotLightPos", transform.position);
                mat.SetColor("_spotLightColor", color);
                mat.SetVector("_spotLightDir", -direction);
            }
        }

    }
}

