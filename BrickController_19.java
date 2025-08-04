package brickcontroller.template;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public abstract class BrickController extends Application {
	
	public final static String LIGHTSTYLE = "-fx-background-color: #00D000; ";

	@Override
	public final void start(Stage primaryStage) {
		primaryStage.setTitle("Brick Controller");
		VBox root = new VBox();
		root.setPadding(new Insets(10));
		root.setSpacing(10);
		root.setAlignment(Pos.CENTER_LEFT);
		primaryStage.setScene(new Scene(root, 250, 150));
		
		populate(root);

		primaryStage.show();
	}
	
	public abstract void populate(VBox root);
}
