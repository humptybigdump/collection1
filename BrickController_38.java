package brickcontroller;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class BrickController extends Application {

	public static void main(String[] args) {
		launch(args);
	}

	public BrickController() {
	}

	public static final String LIGHTSTYLE = "-fx-background-color: #00D000; ";
	
	public void start(Stage primaryStage) {
		primaryStage.setTitle("Brick Controller");
		VBox root = new VBox();
		root.setPadding(new Insets(10));
		root.setSpacing(10);
		root.setAlignment(Pos.CENTER_LEFT);

		populate(root);
		
		primaryStage.setScene(new Scene(root, 250, 150));
		primaryStage.show();
	}
	
	public void addTo(VBox root, Node node) {
		root.getChildren().add(node);
	}
	
	private void populate(VBox root) {
		//Hook Method
	}
}
