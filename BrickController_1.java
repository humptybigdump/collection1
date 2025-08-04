package brickcontroller;

import javafx.application.Application;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.Spinner;
import javafx.scene.control.SpinnerValueFactory.IntegerSpinnerValueFactory;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class BrickController extends Application {

	public static void main(String[] args) {
		launch(args);
	}

	public BrickController() {
	}

	public final String LIGHTSTYLE = "-fx-background-color: #00D000; ";
	
	@Override
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
	
	private void populate(VBox root) {
		//Hook Method
	}
}
