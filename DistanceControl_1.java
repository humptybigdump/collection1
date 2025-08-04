

public class DistanceControl {
	DistanceSensor sensor;

	public DistanceControl(DistanceSensor sensor) {
		this.sensor = sensor;
	}

	/**
	 * Reduces the speed by 10 if a measured object is too close.
	 * 
	 * @return <tt>int</tt> value (km/h), by which the current speed is reduced
	 */
	public int reduceSpeed() {
		if (sensor.isActive() == true) {
			if (sensor.getValue() < 30) {
				return 10;
			} else {
				return 0;
			}
		} else {
			return 0;
		}
	}
}
