const elementId = "myNewDiv"
function renderFile(fbTOKEN, recordId, vID, vURL, tableName, apiUrl) {
  try {
    const skyflow = Skyflow.init({
      vaultID: vID,
      vaultURL: vURL,
      getBearerToken: () => {
        return new Promise((resolve, reject) => {
          const Http = new XMLHttpRequest();
          Http.onreadystatechange = () => {
            if (Http.readyState === 4 && Http.status === 200) {
              const response = JSON.parse(Http.responseText);
              resolve(response.token);
            }
          };
          const url = apiUrl;
          Http.open("GET", url);
          Http.setRequestHeader('Authorization', 'Bearer ' + fbTOKEN);
          Http.send();
        }
        );
      },
    });
    const renderStyleOptions = {
      inputStyles: {
        base: {
          padding: "10px 10px 10px 10px",
          borderRadius: "10px",
          marginTop: "2px",
          height: "100vh",  // update height to 100vh to render page in entire page.
          width: "100%",
        },
      },
      errorTextStyles: {
        base: {
          color: "#f44336",
        },
      },
    };
    const renderContainer = skyflow.container(
      Skyflow.ContainerType.REVEAL,
    );
    const skyflowID = recordId;
    // step 1: create element, pass fetched skyflow id and other details here
    const renderFileElement1 = renderContainer.create({
      ...renderStyleOptions,
      skyflowID: skyflowID,
      column: "file",
      table: tableName,
      altText: "",
    });
    document.body.id = 'myBodyId';
    // step 2: mount the element
    var newDiv = document.createElement('div');
    newDiv.id = elementId;
    newDiv.style.position = "fixed";
    newDiv.style.top = "0";
    newDiv.style.left = "0";
    newDiv.style.width = "100%";
    newDiv.style.height = "100%";
    newDiv.style.zIndex = "9999";
    // Append the new div to the body
    document.body.appendChild(newDiv);
    renderFileElement1.mount("#" + elementId);

    var renderFileHeightEventName = `HEIGHT${renderFileElement1.iframeName()}`
    // Add skyflow SDK height event listener 
    window.addEventListener("message", (event) => { handleUpdateHeight(event, renderFileHeightEventName) });


    // step 3: call render file 
    console.log("RENDER TRIGGER");
    renderFileElement1
      .renderFile()
      .then((res) => {
        console.log("here render");
        console.log("RENDER SUCCESS");
        console.log("response 1", res);
        // remove message event listener, after rendering is successful
        window.addEventListener("message", (event) => { handleUpdateHeight(event, renderFileHeightEventName) });
      })
      .catch((err) => {
        console.log("RENDER ERROR");
        console.log("here 1");
        console.log("Error 1", err);
      });
  } catch (err) {
    console.log(err);
  }
}
function removeElement() {
  var elementToRemove = document.getElementById(elementId);
  // Check if the element with the provided ID exists
  if (elementToRemove) {
    // Remove the element
    elementToRemove.parentNode.removeChild(elementToRemove);
  } else {
    console.warn("Element with ID '" + elementId + "' not found.");
  }
}

// Update height of render element iframe after SDK event. 
function handleUpdateHeight(event, skyflowEventName) {
  if (event?.data?.includes(skyflowEventName)) {
    try {
      // get iframe mounted inside the newDiv
      const renderFileiFrame = document.getElementById(elementId)?.querySelector('iframe');
      if (renderFileiFrame) {
        renderFileiFrame.style.height = "100vh"  // update iframe height to 100vh explictly.
      }
    } catch (err) {
      window.removeEventListener("message", handleUpdateHeight);
    }
  }
}

window.logger = (flutter_value) => {
  console.log({ js_context: this, flutter_value });
}















// const elementId = "myNewDiv"
// function renderFile(fbTOKEN, recordId,vID,vURL,tableName,apiUrl) {



//   try {
//     const skyflow = Skyflow.init({
//       vaultID: vID,
//       vaultURL: vURL,

//       getBearerToken: () => {
//         return new Promise((resolve, reject) => {
//           const Http = new XMLHttpRequest();

//           Http.onreadystatechange = () => {
//             if (Http.readyState === 4 && Http.status === 200) {
//               const response = JSON.parse(Http.responseText);
//               resolve(response.token);
//             }
//           };
//           const url = apiUrl;
//           Http.open("GET", url);
//           Http.setRequestHeader('Authorization', 'Bearer ' + fbTOKEN);

//           Http.send();
//         }


//         );
//       },
//     });

//     const renderStyleOptions = {
//       inputStyles: {
//         base: {

//           padding: "10px 10px 10px 10px",
//           borderRadius: "10px",
//           marginTop: "2px",
//           height: "100%",
//           width: "100%",
//         },
//       },
//       errorTextStyles: {
//         base: {
//           color: "#f44336",
//         },
//       },
//     };

//     const renderContainer = skyflow.container(
//       Skyflow.ContainerType.REVEAL,
//     );

//     const skyflowID = recordId;
//     // step 1: create element, pass fetched skyflow id and other details here
//     const renderFileElement1 = renderContainer.create({
//       ...renderStyleOptions,
//       skyflowID: skyflowID,
//       column: "file",
//       table: tableName,
//       altText: "Alt text 1",
//     });
//     document.body.id = 'myBodyId';

//     // step 2: mount the element
//     var newDiv = document.createElement('div');
//     newDiv.id = elementId;
//     newDiv.style.position = "fixed";
//     newDiv.style.top = "0";
//     newDiv.style.left = "0";
//     newDiv.style.width = "100%";
//     newDiv.style.height = "100%";
//     newDiv.style.zIndex = "9999";

//     // Append the new div to the body
//     document.body.appendChild(newDiv);
//     renderFileElement1.mount("#" + elementId);

//     // step 3: call render file 
//     console.log("RENDER TRIGGER");
//     renderFileElement1
//       .renderFile()
//       .then((res) => {
//         console.log("here render");
//         console.log("RENDER SUCCESS");

//         console.log("response 1", res);
//       })
//       .catch((err) => {
//         console.log("RENDER ERROR");

//         console.log("here 1");
//         console.log("Error 1", err);
//       });
//   } catch (err) {
//     console.log(err);
//   }
// }
// function removeElement() {
//   var elementToRemove = document.getElementById(elementId);

//   // Check if the element with the provided ID exists
//   if (elementToRemove) {
//     // Remove the element
//     elementToRemove.parentNode.removeChild(elementToRemove);
//   } else {
//     console.warn("Element with ID '" + elementId + "' not found.");
//   }
// }


// window.logger = (flutter_value) => {
//   console.log({ js_context: this, flutter_value });
// }
