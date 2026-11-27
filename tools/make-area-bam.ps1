# Builds BattleSense/copy/spellinfo/ZJSPLARE.BAM, the areas the Spell Info module draws on the ground.
#
# One sequence per color, each with one frame. There is one: white, which ZJSplInf.menu tints with the color of the
# area's option. The frame is a 256x192 ellipse, (the engine stretches distances vertically by 4/3, so its circles are 4:3 ellipses on screen),
# with a faint fill and a stronger rim. The label scales it to the area's size.
#
# The see-through parts use the alpha channel of the palette, which the Enhanced Editions honor, (1 - 255, 0 = opaque).
# Every color gets `levels` palette entries of increasing alpha, so the rim's edge can fade out smoothly.
#
# Run from anywhere: powershell -ExecutionPolicy Bypass -File tools\make-area-bam.ps1

# The leading comma keeps PowerShell from flattening a list of one color
$colors = [byte[][]]@(
	,[byte[]](255, 255, 255) # 0 = Every area, (white, tinted by the menu)
)

$source = @'
using System; using System.IO; using System.Text;
public static class ZJAreaBam {
	public static int Make(string outPath, byte[][] colors) {
		const int w = 256, h = 192, n = w * h, levels = 85, samples = 4;
		const double fillAlpha = 0.35, rimAlpha = 1.0, rimWidth = 3.0;
		int colorCount = colors.Length;
		int framesPerColor = 1, total = framesPerColor * colorCount;
		int perColorData = n;
		int frameEntries = 24, cycles = frameEntries + total * 12, palette = cycles + colorCount * 4;
		int lookup = palette + 1024, data = lookup + total * 2;
		var o = new byte[data + colorCount * perColorData];

		Encoding.ASCII.GetBytes("BAM V1  ").CopyTo(o, 0);
		BitConverter.GetBytes((ushort)total).CopyTo(o, 8);
		o[10] = (byte)colorCount;
		o[11] = 0; // RLE color, unused: every frame is stored uncompressed
		BitConverter.GetBytes(frameEntries).CopyTo(o, 12);
		BitConverter.GetBytes(palette).CopyTo(o, 16);
		BitConverter.GetBytes(lookup).CopyTo(o, 20);

		// Palette (BGRA): 0 = transparent green, 1 + c * levels + (l - 1) = color c at alpha level l
		o[palette + 1] = 255;
		for (int c = 0; c < colorCount; c++) {
			for (int l = 1; l <= levels; l++) {
				int q = palette + (1 + c * levels + (l - 1)) * 4;
				o[q] = colors[c][2]; o[q + 1] = colors[c][1]; o[q + 2] = colors[c][0];
				o[q + 3] = (byte)Math.Round(l * 255.0 / levels); // Never 0, which would be opaque
			}
		}

		// The alpha of every pixel, the same for every color: how much of it lies inside the ellipse, (the rim), and
		// inside the ellipse shrunk by the rim's width, (the fill)
		double rx = w / 2.0, ry = h / 2.0, irx = rx - rimWidth, iry = ry - rimWidth;
		var alphaLevel = new int[n];
		for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
			int outer = 0, inner = 0;
			for (int sy = 0; sy < samples; sy++) for (int sx = 0; sx < samples; sx++) {
				double px = x + (sx + 0.5) / samples - rx, py = y + (sy + 0.5) / samples - ry;
				if ((px * px) / (rx * rx) + (py * py) / (ry * ry) <= 1.0) outer++;
				if ((px * px) / (irx * irx) + (py * py) / (iry * iry) <= 1.0) inner++;
			}
			double count = samples * samples;
			double alpha = fillAlpha * inner / count + rimAlpha * (outer - inner) / count;
			alphaLevel[y * w + x] = (int)Math.Round(alpha * levels);
		}

		int frame = 0, p = data;

		// Writes the frame showing the image's pixels (x0, y0) - (x0 + fw, y0 + fh) in color c
		Action<int, int, int, int, int> write = (c, x0, y0, fw, fh) => {
			int e = frameEntries + frame * 12;
			BitConverter.GetBytes((ushort)fw).CopyTo(o, e);
			BitConverter.GetBytes((ushort)fh).CopyTo(o, e + 2);
			BitConverter.GetBytes((uint)p | 0x80000000u).CopyTo(o, e + 8);
			for (int y = 0; y < fh; y++) for (int x = 0; x < fw; x++) {
				int l = alphaLevel[(y0 + y) * w + (x0 + x)];
				o[p++] = l <= 0 ? (byte)0 : (byte)(1 + c * levels + (l - 1));
			}
			BitConverter.GetBytes((ushort)frame).CopyTo(o, lookup + frame * 2);
			frame++;
		};

		for (int c = 0; c < colorCount; c++) {
			BitConverter.GetBytes((ushort)framesPerColor).CopyTo(o, cycles + c * 4);
			BitConverter.GetBytes((ushort)(c * framesPerColor)).CopyTo(o, cycles + c * 4 + 2);
			write(c, 0, 0, w, h);
		}

		File.WriteAllBytes(outPath, o);
		return o.Length;
	}
}
'@

Add-Type -TypeDefinition $source
$out = Join-Path $PSScriptRoot "..\BattleSense\copy\spellinfo\ZJSPLARE.BAM"
$size = [ZJAreaBam]::Make([IO.Path]::GetFullPath($out), $colors)
"Wrote $out ($size bytes)"
