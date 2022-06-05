using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct GameObjectInfo
{
    public Vector3 position;
    public Vector3 velocity;
    public Vector3 speed;
    public Vector3 acceleration;
    public Vector3 force;
    public Vector3 target;
    public Vector3 cohesion;
    public Vector3 alignment;
    public Vector3 separation;
    public static int Size
    {
        get
        {
            return sizeof(float) * 3 * 9;
        }
    }
}


public class SimpleComputePersistent : MonoBehaviour
{
    public GameObject prefab;
    public ComputeShader shader;

    public int maxObjectsSpawn = 68;
    List<GameObject> objects;
    ComputeBuffer dataBuffer;
    GameObjectInfo[] data;
    public Transform[] targets;
    public Transform startTarget;
    [Range(0.1f, 10)] public float minVelocity;
    [Range(0.1f, 10)] public float maxVelocity;
    float[] randomVelocities;
    public float seekForce = 1.0f;
    public float cohesionForce = 0.5f;
    public float separationForce = 0.5f;
    public float alignForce = 0.5f;

    // Start is called before the first frame update
    void Start()
    {
        //We create the objects to move
        objects = new List<GameObject>(maxObjectsSpawn);
        for (int i = 0; i < maxObjectsSpawn; i++)
        {
            GameObject newObj = Instantiate(prefab, transform);
            Vector3 randomPosition = new Vector3(Random.Range(0.0f, 3.0f), Random.Range(0.0f, 3.0f), Random.Range(0.0f, 3.0f));
            newObj.transform.position = transform.position + randomPosition;
            objects.Add(newObj);
        }
        //we generate the data array to pass data from CPU to GPU at the initialization, and don't release the buffer until destroy is called

        int numObjs = objects.Count;
        data = new GameObjectInfo[numObjs];
        randomVelocities = new float[numObjs];
        for (int i = 0; i < numObjs; i++)
        {
            randomVelocities[i] = Random.Range(minVelocity, maxVelocity);
            data[i].speed = Vector3.one * randomVelocities[i];
            data[i].target = startTarget.transform.position;
            data[i].position = objects[i].transform.position;
            data[i].velocity = Vector3.zero;

            data[i].force = Seek(i, data[i].target);
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
            }
            
            Vector3 steeringForce = Vector3.zero;
            steeringForce += Seek(i, data[i].target) * seekForce;
            steeringForce += Cohesion(i) * cohesionForce;
            steeringForce += Separation(i) * separationForce;
            steeringForce += Alignment(i) * alignForce;

            data[i].force = steeringForce;

            // Update gameobjects positions
            objects[i].transform.position = data[i].position;
        }

        dataBuffer.SetData(data);
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

    public Vector3 Cohesion(int id)
    {
        Vector3 cohesionVector = Vector3.zero;

        for (int i = 0; i < objects.Count; i++)
        {
            if (i != id)
            {
                cohesionVector += data[i].position;
            }
        }
        cohesionVector /= objects.Count - 1;
        cohesionVector -= data[id].position;
        
        cohesionVector.Normalize();
        cohesionVector *= randomVelocities[id];
        Vector3 steeringForce = cohesionVector - data[id].velocity;
        steeringForce.Normalize();

        return steeringForce;
    }
    public Vector3 Separation(int id)
    {
        Vector3 separateVector = Vector3.zero;

        for (int i = 0; i < objects.Count; i++)
        {
            if (i != id)
            {
                separateVector += data[id].position - data[i].position;
            }
        }
        separateVector /= objects.Count - 1;

        separateVector.Normalize();
        separateVector *= randomVelocities[id];
        Vector3 steeringForce = separateVector - data[id].velocity;
        steeringForce.Normalize();

        return steeringForce;
    }
    public Vector3 Alignment(int id)
    {
        Vector3 alignVector = Vector3.zero;

        for (int i = 0; i < objects.Count; i++)
        {
            if (i != id)
            {
                alignVector += data[i].velocity;
            }
        }
        alignVector /= objects.Count - 1;

        alignVector.Normalize();
        alignVector *= randomVelocities[id];
        Vector3 steeringForce = alignVector - data[id].velocity;
        steeringForce.Normalize();

        return steeringForce;
    }
    public Vector3 Seek(int id, Vector3 target)
    {
        Vector3 desiredVelocity = target - data[id].position;
        desiredVelocity.Normalize();
        desiredVelocity *= randomVelocities[id];
        Vector3 steeringForce = desiredVelocity - data[id].velocity;
        steeringForce.Normalize();

        return steeringForce;
    }

}