using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct GameObjectInfo
{
    public Vector3 position;
    public Vector3 velocity;
    public Vector3 target;
    public Vector3 cohesion;
    public Vector3 alignment;
    public Vector3 separation;
    public static int Size
    {
        get
        {
            return sizeof(float) * 3 * 6;
        }
    }
}


public class SimpleComputePersistent : MonoBehaviour
{
    public GameObject prefab;
    public ComputeShader shader;

    public int numObjectsPerRow = 10;
    List<GameObject> objects;
    ComputeBuffer dataBuffer;
    GameObjectInfo[] data;
    public Transform[] targets;
    public Transform startTarget;
    public float minVelocity = 0.1f;
    int[] ids;
    [Range(0.1f,10)] public float maxVelocity;
    float[] randomVelocities;
    
    // Start is called before the first frame update
    void Start()
    {
        //We create the objects to move
        objects = new List<GameObject>(numObjectsPerRow * numObjectsPerRow);
        for (int i = 0; i < numObjectsPerRow; i++)
        {
            for (int j = 0; j < numObjectsPerRow; j++)
            {
                GameObject newObj = Instantiate(prefab, transform);
                Vector3 randomPosition = new Vector3(Random.Range(0, 3), Random.Range(0, 3), Random.Range(0, 3));
                newObj.transform.position = transform.position + randomPosition;
                objects.Add(newObj);
            }
        }
        //we generate the data array to pass data from CPU to GPU at the initialization, and don't release the buffer until destroy is called

        int numObjs = objects.Count;
        data = new GameObjectInfo[numObjs];
        randomVelocities = new float[numObjs];
        ids = new int[numObjs];
        
        for (int i = 0; i < numObjs; i++)
        {
            randomVelocities[i] = Random.Range(minVelocity, maxVelocity);
            
            data[i].target = startTarget.transform.position;
            data[i].velocity = new Vector3(1,1,1) * randomVelocities[i];
            data[i].position = objects[i].transform.position;

            ids[i] = i;
        }
        //We create the buffer to pass data to the GPU
        //The constructor asks for an ammount of objects for the buffer and the size of each object in bytes
        dataBuffer = new ComputeBuffer(numObjs, GameObjectInfo.Size);
        //We load the data into the buffer
        dataBuffer.SetData(data);
    }
    
    // Update is called once per frame
    void Update()
    {
        //we generate the data array to pass data from CPU to GPU
        int numObjs = objects.Count;
        int kernelHandle = shader.FindKernel("CSMain");
        shader.SetBuffer(kernelHandle, "CoolerResult", dataBuffer);
        shader.SetFloat("deltaTime", Time.deltaTime);
        
        int threadGroups = Mathf.CeilToInt(numObjs / 128.0f);

        shader.Dispatch(kernelHandle, threadGroups, 1, 1);

        dataBuffer.GetData(data);
        for (int i = 0; i < numObjs; i++)
        {
            if (Vector3.Distance(data[i].position, data[i].target) < 3)
            {
                data[i].target = CalculateNewTarget(data[i].target);
                dataBuffer.SetData(data);
            }

            objects[i].transform.position = data[i].position;
        }

        //dataBuffer.Release();
    }

    private Vector3 CalculateNewTarget(Vector3 currentTarget)
    {
        if (currentTarget == targets[targets.Length - 1].position) return targets[0].transform.position;

        for (int i = 0; i < targets.Length; i++)
        {
            if (currentTarget == targets[i].position)
            {
                return targets[i + 1].transform.position;
            }
        }
        
        return startTarget.transform.position;
    }
    
    public void OnDestroy()
    {
        foreach (Transform child in transform)
        {
            GameObject.Destroy(child.gameObject);
        }
        dataBuffer.Release();
    }

    public Vector3 GetTarget(Vector3 ownPos, Vector3 newPos)
    {
        return ownPos - newPos;
    }

    public Vector3 Cohesion()
    {
        Vector3 averageVector = Vector3.zero;

        return Vector3.zero;
    }
    public Vector3 Separation()
    {
        Vector3 averageVector = Vector3.zero;

        return Vector3.zero;
    }
    public Vector3 Alignment()
    {
        Vector3 averageVector = Vector3.zero;

        return Vector3.zero;
    }

}