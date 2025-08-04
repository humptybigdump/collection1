package vl06;

class Dori {
	static byte b;
	static char c;
	static float f;

	static void nemo(long l, float f) {
		System.out.println("l, f");
	}

	static void nemo(byte b, int i) {
		System.out.println("b, i");
	}

	static void nemo(double d, long l) {
		System.out.println("d, l");
	}

	public static void main(String[] args) {
		nemo(b, c);
		nemo(f, c);
		nemo(c, f);
	}
}
