package utils;

import java.io.IOException;

import org.json.JSONException;
import org.json.JSONObject;

import config.Config;
import pygmy.com.utils.HttpRESTUtils;

public class TestUtils {

    public static int updateStock(String catalogServerURL, String uiServerURL,
            String bookId, int updateBy)
            throws JSONException, IOException {

        // get the initial count in stock
        JSONObject queryResponse = new JSONObject(
                HttpRESTUtils.httpGet(uiServerURL + "/lookup/" + bookId, Config.DEBUG));
        int initialCount = queryResponse.getInt("Stock");

        // send a JSON POST request to catalog-server to add to stock
        JSONObject updateRequest = new JSONObject();
        updateRequest.put("bookId", bookId);
        updateRequest.put("updateBy", updateBy);

        JSONObject updateResponse = new JSONObject(
                HttpRESTUtils.httpPostJSON(catalogServerURL + "/update", updateRequest,
                        Config.DEBUG));
        int finalCount = updateResponse.getInt("Stock");

        assert finalCount == initialCount + updateBy;
        System.out.println("Updated stock of book: " + bookId + " to " + finalCount);
        return finalCount;
    }

}
