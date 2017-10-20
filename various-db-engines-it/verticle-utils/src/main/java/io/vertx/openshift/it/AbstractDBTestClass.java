package io.vertx.openshift.it;

import com.jayway.restassured.http.ContentType;
import com.jayway.restassured.response.Response;
import com.jayway.restassured.specification.RequestSpecification;
import io.fabric8.kubernetes.api.KubernetesHelper;
import io.fabric8.kubernetes.api.model.Pod;
import io.fabric8.kubernetes.api.model.PodList;
import io.fabric8.kubernetes.api.model.PodStatus;
import io.fabric8.kubernetes.api.model.ServiceStatus;
import io.vertx.it.openshift.utils.AbstractTestClass;
import io.vertx.it.openshift.utils.OC;
import org.json.JSONObject;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import static com.jayway.restassured.RestAssured.*;
import static io.vertx.it.openshift.utils.Ensure.ensureThat;
import static io.vertx.it.openshift.utils.Kube.awaitUntilPodIsReady;
import static io.vertx.it.openshift.utils.Kube.name;
import static org.hamcrest.core.IsEqual.equalTo;


public abstract class AbstractDBTestClass extends AbstractTestClass {

  public static final String API_LIST_ROUTE = "/api/vegetables/";
  public static final String DB_NAME = "db";
  public static final int WAIT = 10;
  public static final int WAIT_CYCLES = 10;
  private String dump;

  //TODO DB is empty after scale down DB
  @Test
  public void restartDBTest() throws Exception {
    System.out.println("Start DB restart test");
    shutDownDB();
    TimeUnit.SECONDS.sleep(WAIT);
    startDB();
    awaitUntilPodIsReady(client,DB_NAME);
    TimeUnit.SECONDS.sleep(WAIT);
    CRUDTest();
  }


  @Test
  @Ignore
  public void runDBAfterDeployAppTest () throws Exception {
    System.out.println("Start test run DB after deploy app");
    cleanup();
    System.out.println("App was deleted!");
    shutDownDB();
    System.out.println("DB was scaled to 0 pod!");
    deploymentAssistant.deployApplication();
    System.out.println("Deploy app and wait " + WAIT + " seconds when app is ready");
    TimeUnit.SECONDS.sleep(WAIT);
    System.out.println("DB was scaled to 1 pod! and wait");
    startDB();
    for (int waitCycle = 0; waitCycle<WAIT_CYCLES;waitCycle++){
      if( get("/healthcheck").statusCode() == 200){
        break;
      }
      TimeUnit.SECONDS.sleep(WAIT);
    }
    ensureThat("Test if app is fully deployed", () -> get("/healthcheck").then().assertThat().statusCode(200));
    //Test if app is connected to DB
    CRUDTest();
  }

  private void shutDownDB() throws Exception {
    dumpDB();
    scaleDB(0);
  }
  private void dumpDB () throws Exception {
    this.dump = OC.execute("exec", "-p", getPodId(DB_NAME) , "--", "/opt/rh/rh-mysql57/root/usr/bin/mysqldump", "-u", "vertx", "-ppassword", "--all-databases");
  }

  private void startDB() throws Exception {
    scaleDB(1);
    TimeUnit.SECONDS.sleep(WAIT);
    restoreDB();
  }

  private void restoreDB () throws Exception {
    OC.execute("exec", "-p", getPodId(DB_NAME) , "--", "echo", "\"" + this.dump + "\" >&2", "|","/opt/rh/rh-mysql57/root/usr/bin/mysql", "-u", "vertx", "-ppassword");
  }

  private String getPodId (String name) throws Exception {
    for (Pod pod : client.pods().list().getItems()){
      String podName = name(pod);
      if (podName.startsWith(name) && !podName.endsWith("-build")) {
        return podName;
      }
    }
    throw new Exception("Pod " + name + " doesn\'t exist");
  }

  private void scaleDB (int replicas) {
    OC.execute("scale","deploymentconfig", "--replicas="+replicas, DB_NAME );
  }


  @Test
  public void CRUDTest() {
    System.out.println("Start CRUD test");
    String vegetableName = "Pickles";
    String updatedVegetableName = "Cucumbers";
    int ammoutOfVegetable = 128;

    //Test create new item
    Response postResponse = createItem(vegetableName);
    ensureThat("Test of response of create new vegetable", () -> postResponse.then().assertThat().body("name", equalTo(vegetableName)));
    int vegetableId = postResponse.getBody().jsonPath().getInt("id");

    //Test get created
    ensureThat("Get created vegetable", () -> get(API_LIST_ROUTE+vegetableId).then().assertThat().body("name",equalTo(vegetableName)));

    //Test update created
    JSONObject modifyVegetable = new JSONObject().put("name",updatedVegetableName).put("amount",ammoutOfVegetable).put("id",vegetableId);
    ensureThat("Update one item", () -> updateItem(vegetableId,modifyVegetable).then().assertThat().body("name", equalTo("Cucumbers")).and().body("amount",equalTo(ammoutOfVegetable)));

    //Test updated
    ensureThat("Get created vegetable", () -> get(API_LIST_ROUTE+vegetableId).then().assertThat().body("name",equalTo(updatedVegetableName)).and().body("amount",equalTo(ammoutOfVegetable)));

    //Test delete one
    ensureThat("Delete item", () -> delete(API_LIST_ROUTE+vegetableId).then().assertThat().statusCode(204));

    //Test get deleted
    ensureThat("Get created vegetable", () -> get(API_LIST_ROUTE+vegetableId).then().assertThat().statusCode(404));
  }

  public Response createItem (String name) {
    return setRequestJSONBody(new JSONObject().put("name",name)).post(API_LIST_ROUTE);
  }
  public Response updateItem (int id ,JSONObject body) {
    return  setRequestJSONBody(body).put(API_LIST_ROUTE+id);
  }

  private RequestSpecification setRequestJSONBody (JSONObject body) {
    return given().content(ContentType.JSON).body(body.toString());
  }

  @AfterClass
  public static void dbCleanup() throws IOException {
    client.deploymentConfigs().withName(DB_NAME).withGracePeriod(0).delete();
    client.services().withName(DB_NAME).withGracePeriod(0).delete();
    client.imageStreams().withName(DB_NAME).withGracePeriod(0).delete();
  }

}
