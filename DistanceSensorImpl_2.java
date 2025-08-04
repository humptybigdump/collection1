

public class DistanceSensorImpl implements DistanceSensor{

	@Override
	public boolean isActive() {
		return true;
	}

	@Override
	public double getValue() {
		double p = 0.0;
		// read hardware
		p = Math.random() * 100000;
		return p;
	}
}
