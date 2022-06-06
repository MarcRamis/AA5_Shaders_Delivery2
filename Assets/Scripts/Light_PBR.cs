using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Light_PBR : MonoBehaviour
{
    public enum LightType { Point, Directional, Spot };
    public LightType type;
    public Vector3 direction;
    public Color color;
    public float intensity;

    Material lightMat;
    public Material[] mats;

    //DIRECTIONAL_LIGHT
    public GameObject[] directional_Lights;
    //POINT_LIGHT
    public GameObject[] point_Lights;
    //SPOT_LIGHT
    public GameObject[] spot_Lights;


    // Start is called before the first frame update
    void OnEnable()
    {
        direction = transform.forward;
        //mat = ;
        if (point_Lights.Length != 0)
        {
            Shader.EnableKeyword("POINT_LIGHT_ON");
            //lightMat = GetComponent<Renderer>().sharedMaterial;
        }
        if (directional_Lights.Length != 0)
        {
            Shader.EnableKeyword("DIRECTIONAL_LIGHT_ON");
        }
        if (spot_Lights.Length != 0)
        {
            Shader.EnableKeyword("SPOT_LIGHT_ON");
        }
            

    }
    private void OnDisable()
    {
        if (point_Lights.Length == 0)
        {
            Shader.DisableKeyword("POINT_LIGHT_ON");
        }
        if (directional_Lights.Length == 0)
        {
            Shader.DisableKeyword("DIRECTIONAL_LIGHT_ON");
        }
        if (spot_Lights.Length == 0)
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
        //DIRECTIONAL_LIGHT
        Vector4[] direct_Direction = new Vector4[directional_Lights.Length];
        Color[] direct_Color = new Color[directional_Lights.Length];
        //POINT_LIGHT
        Vector4[] point_Pos = new Vector4[point_Lights.Length];
        Color[] point_Color = new Color[point_Lights.Length];
        //SPOT_LIGHT
        Vector4[] spot_Direction = new Vector4[spot_Lights.Length];
        Color[] spot_Color = new Color[spot_Lights.Length];
        Vector4[] spot_Pos = new Vector4[spot_Lights.Length];

        for(int i = 0; i < directional_Lights.Length; i++)
        {
            direct_Direction[i] = -directional_Lights[i].transform.forward;
            direct_Color[i] = directional_Lights[i].GetComponent<Light_Struct>().color;
        }
        for (int i = 0; i < point_Lights.Length; i++)
        {
            point_Pos[i] = point_Lights[i].transform.position;
            point_Color[i] = point_Lights[i].GetComponent<Light_Struct>().color;
        }
        for (int i = 0; i < spot_Lights.Length; i++)
        {
            spot_Direction[i] = -spot_Lights[i].transform.forward;
            spot_Color[i] = spot_Lights[i].GetComponent<Light_Struct>().color;
            spot_Pos[i] = spot_Lights[i].transform.position;
        }

        foreach (Material mat in mats)
        {

            mat.SetInt("_directionalSize", directional_Lights.Length);
            mat.SetVectorArray("_directionalLightDirections", direct_Direction);
            mat.SetColorArray("_directionalLightColors", direct_Color);

            mat.SetInt("_pointSize", point_Lights.Length);
            mat.SetVectorArray("_pointLightPositions", point_Pos);
            mat.SetColorArray("_pointLightColors", point_Color);
           
            mat.SetInt("_spotSize", spot_Lights.Length);
            mat.SetVectorArray("_spotLightPositions", spot_Pos);
            mat.SetColorArray("_spotLightColors", spot_Color);
            mat.SetVectorArray("_spotLightDirections", spot_Direction);

        }

    }
}

