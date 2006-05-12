import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintStream;
import java.util.Iterator;
import java.util.Vector;

/**
 * Compile all the source files into one, and pack with the dojo toolkit
 * javascript packer.
 * 
 * @author Stefan Kestenholz (keschte)
 * @version 1.0
 */
public class Packer {

	/**
	 * Compile all the source files into one, and pack with the dojo toolkit
	 * javascript packer.
	 * 
	 * @param args
	 *            the list of configuration files.
	 */
	public static void main(String[] args) throws Exception {

		File f = new File(args[0]);
		Vector<File> files = new Vector<File>();
		String lib = "";
		if (f.exists()) {
			String line;

			BufferedReader br = new BufferedReader(new FileReader(f));
			File srcDir = null;
			File buildDir = null;
			File packedDir = null;
			File deployDir = null;

			String key, val;
			while ((line = br.readLine()) != null) {
				try {
					key = line.split("=")[0];
					val = line.split("=")[1];

					if (key.equals("src")) {
						srcDir = new File(val);
						System.out.println("Got srcdir=" + srcDir);

					} else if (key.equals("build")) {
						buildDir = new File(val);
						buildDir.mkdirs();

					} else if (key.equals("packed")) {
						packedDir = new File(val);
						packedDir.mkdirs();

					} else if (key.equals("deploy")) {
						deployDir = new File(val);
						System.out.println("Got deployDir=" + deployDir);

					} else {
						if (srcDir != null && buildDir != null) {
							if (key.equals("lib")) {
								lib = val;
							} else {
								if (val.indexOf("*") == -1) {
									f = new File(srcDir, val);
									files.addElement(f);
								} else {
									val = val.replaceAll("\\*", "");

									File includeDir = new File(srcDir, val);
									File[] fl = includeDir.listFiles();
									System.out.println("Slurping... "
											+ includeDir.getAbsolutePath());

									if (fl != null) {
										for (int i = 0; i < fl.length; i++) {
											f = fl[i];
											if (!f.isDirectory()) {
												files.addElement(f);
											}
										}
									}
								}
							}
						}
					}
				} catch (ArrayIndexOutOfBoundsException ex) {
				}
			}
			br.close();

			System.out.println(files);

			BufferedReader in = null;
			BufferedWriter out = null;
			if (deployDir != null && buildDir != null) {

				File fin = new File(buildDir, lib);
				File fpacked = new File(packedDir, fin.getName());
				File fdeploy = new File(deployDir, fin.getName());

				// dump the source files of the lib.
				System.out.println("Collecting " + fin.getName() + "...");
				System.out.print("* ");
				for (Iterator it = files.iterator(); it.hasNext();) {
					System.out.print(((File) it.next()).getName()
							+ (it.hasNext() ? "," : ""));
				}
				System.out.println();

				// slurp the contents of the lib into one file
				try {
					out = new BufferedWriter(new FileWriter(fin));
					for (Iterator it = files.iterator(); it.hasNext();) {
						in = new BufferedReader(
								new FileReader((File) it.next()));
						for (String s; (s = in.readLine()) != null;) {
							out.write(s);
							out.newLine();
						}
						in.close();
					}

				} catch (IOException e) {
					System.err.println(e);
					System.exit(-1);
				} finally {
					try {
						if (in != null)
							in.close();
						if (out != null)
							out.close();
					} catch (IOException e) {
					}
				}

				// set deploy location
				System.out.println("Compressing " + fpacked.getName() + "...");

				// write output to deploy destination
				PrintStream psout = new PrintStream(new FileOutputStream(
						fpacked));
				org.mozilla.javascript.tools.shell.Main.setOut(psout);
				org.mozilla.javascript.tools.shell.Main.exec(new String[] {
						"-c", fin.getAbsolutePath() });
				psout.close();

				// slurp the contents of the lib into one file
				in = null;
				out = null;
				StringBuffer buf = new StringBuffer();
				try {
					in = new BufferedReader(new FileReader(fpacked));
					for (String s; (s = in.readLine()) != null;) {
						buf.append(s);
						buf.append("\n");
					}
					in.close();
				} catch (IOException e) {
					System.err.println(e);
					System.exit(-1);
				}
				String s = buf.toString();

				org.mozilla.javascript.tools.shell.Main.setOut(null);

				/*
				 * Hashtable<Object, Object> g = new Hashtable<Object,
				 * Object>(); g.put("error",""); g.put("warning","");
				 * g.put("info",""); g.put("debug",""); g.put("writeui","");
				 * g.put("scopestart",""); g.put("scopeend","");
				 * g.put("setuppopuplinks","");
				 * 
				 * System.out.println(); System.out.println("Replacing
				 * functions...");
				 * 
				 * Hashtable<String, String> x = new Hashtable<String,
				 * String>(); Pattern p =
				 * Pattern.compile("this\\.([a-z0-9]+)\\s*=\\s*function\\(",
				 * Pattern.CASE_INSENSITIVE); Matcher m = p.matcher(s); int i=0;
				 * while (m.find()) { String oname = m.group(1); if
				 * (g.get(oname.toLowerCase()) == null && x.get(oname) == null &&
				 * oname.length()>4) { String nname = "__"+(i++);
				 * System.out.println("* "+oname+" "+nname); x.put(oname,
				 * nname); s = s.replaceAll("\\."+oname+"\\(", "."+nname+"("); s =
				 * s.replaceAll("\\."+oname+" ", "."+nname+" "); } }
				 * 
				 * p = Pattern.compile("this\\.([^_]([A-Z0-9_]+))"); m =
				 * p.matcher(s); x = new Hashtable<String, String>(); i=0;
				 * System.out.println(); System.out.println("Replacing
				 * constants..."); while (m.find()) { String oname = m.group(1);
				 * if (g.get(oname.toLowerCase()) == null && x.get(oname) ==
				 * null && oname.length()>4) { String nname = "_c_"+(i++);
				 * System.out.println("* "+oname+" "+nname); x.put(oname,
				 * nname); s = s.replaceAll(oname, nname); } }
				 */

				FileWriter fw = new FileWriter(fdeploy);
				fw.write(s);
				fw.close();
			}
		}
	}
}