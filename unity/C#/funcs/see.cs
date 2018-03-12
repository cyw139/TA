using UnityEngine;
using System.Collections;

public class see : MonoBehaviour {

	float speed_FB = 0F;
	float speed_LR = 0F;

	float sensitivityX = 5.0f;   
	float sensitivityY = 5.0f; 
	float rotationY = 0F;
	float rotationX = 0F;

	float UpDown = 0.0f;

	Vector3 worldmovedir = new Vector3(0,0,0);
	Vector3 localmovedir = new Vector3(0,0,0);
    void Star() 
    { 
		
    }


    void FixedUpdate()
    {
		if (Input.GetKey (KeyCode.LeftShift)) {
			speed_FB = 80.0f; 
			speed_LR = 80.0f;
			UpDown = 2.0f;
		} else if (Input.GetKey (KeyCode.Space)) {
			speed_FB = 1.0f;
			speed_LR = 1.5f;
			UpDown = 0.07f;
		} 
		else 
		{
			speed_FB = 10.0f;
			speed_LR = 10.0f;
			UpDown = 1.0f;
		}

		Cursor.visible = false;
		rotationX = transform.localEulerAngles.y + Input.GetAxis("Mouse X") * sensitivityX;
		rotationY += Input.GetAxis("Mouse Y") * sensitivityY; 

        float translation_FB = Input.GetAxis("Vertical") * speed_FB * Time.deltaTime;
		float translation_LR = Input.GetAxis("Horizontal") * speed_LR * Time.deltaTime;

        if (Input.GetKey(KeyCode.E))
        {
			worldmovedir.y = 0.1f * UpDown;
			localmovedir = transform.worldToLocalMatrix.MultiplyVector (worldmovedir);
			transform.Translate (localmovedir);
        }
        if (Input.GetKey(KeyCode.Q))
        {
			worldmovedir.y = -0.1f * UpDown;
			localmovedir = transform.worldToLocalMatrix.MultiplyVector (worldmovedir);
			transform.Translate (localmovedir);
        }

		transform.Translate(translation_LR, 0, translation_FB);

		rotationY = Mathf.Clamp (rotationY, -89.0f, 89.0f);
		transform.localEulerAngles = new Vector3(-rotationY, rotationX, 0);


//渲染挂载的模型        
        //if (Input.GetKeyDown(KeyCode.Z))
        //{
        //    if (gameObject.GetComponent<MeshRenderer>().enabled)
        //    {
        //        gameObject.GetComponent<MeshRenderer>().enabled = false;
        //    }
        //    else
        //    {
        //        gameObject.GetComponent<MeshRenderer>().enabled = true;
        //    }
        //}





    }
}
