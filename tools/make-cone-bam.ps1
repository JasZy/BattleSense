# Builds BattleSense/copy/spellinfo/ZJSPLCON.BAM, the cone shaped areas the Spell Info module draws on the ground.
#
# A cone starts at the caster and points where the spell is aimed. The engine measures its radius and angle with the
# vertical axis stretched by 4/3, so on screen it is a slice of a 4:3 ellipse, (like ZJSPLARE.BAM's circles). A menu
# can't rotate an image, so every frame is the whole 192x144 ellipse box, centered on the caster, with the slice
# pointing in one of `directions` directions drawn in.
#
# One sequence per cone width, (ZJSpellInfo_Private_ConeWidths in ZJSplInf.lua, the widths of the game's cone
# projectiles), with `directions` frames: frame d points at d * 360 / directions degrees, 0 = east, counting clockwise
# on screen, (towards south), in the stretched space.
#
# Frames are RLE compressed, (transparent index 0), most of each frame is empty.
#
# Run from anywhere: powershell -ExecutionPolicy Bypass -File tools\make-cone-bam.ps1

$widths = [int[]]@(45, 90, 120, 140)
$color = [byte[]](255, 255, 255) # White, ZJSplInf.menu tints it with the color of the spell area option

$source = @'
using System; using System.IO; using System.Text; using System.Collections.Generic;
public static class ZJConeBam {
	public static int Make(string outPath, int[] widths, byte[] color) {
		const int w = 192, h = 144, levels = 85, samples = 4, directions = 64;
		const double fillAlpha = 0.35, rimAlpha = 1.0, rimWidth = 2.5;
		int seqCount = widths.Length, total = seqCount * directions;

		var frames = new List<byte[]>();
		double half = w / 2.0;
		double rim = rimWidth / half; // In units of the radius

		foreach (int width in widths) {
			double halfAngle = width * Math.PI / 360.0;
			for (int d = 0; d < directions; d++) {
				double dir = d * 2 * Math.PI / directions;
				var levelsOut = new int[w * h];
				for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
					int outer = 0, inner = 0;
					for (int sy = 0; sy < samples; sy++) for (int sx = 0; sx < samples; sx++) {
						// Normalized, (the radius is 1), in the stretched space: h / 2 is 3 / 4 of w / 2
						double nx = (x + (sx + 0.5) / samples - w / 2.0) / half;
						double ny = (y + (sy + 0.5) / samples - h / 2.0) / (h / 2.0);
						double r = Math.Sqrt(nx * nx + ny * ny);
						if (r > 1.0) continue;
						double diff = Math.Atan2(ny, nx) - dir;
						while (diff > Math.PI) diff -= 2 * Math.PI;
						while (diff < -Math.PI) diff += 2 * Math.PI;
						double ad = Math.Abs(diff);
						if (ad > halfAngle) continue;
						outer++;
						// Inside the rim: away from the arc and from both straight edges
						if (r <= 1.0 - rim && r * Math.Sin(halfAngle - ad) >= rim) inner++;
					}
					double count = samples * samples;
					double alpha = fillAlpha * inner / count + rimAlpha * (outer - inner) / count;
					levelsOut[y * w + x] = (int)Math.Round(alpha * levels);
				}

				// RLE: index 0 followed by a count c stands for c + 1 transparent pixels
				var data = new List<byte>();
				int i = 0;
				while (i < w * h) {
					int l = levelsOut[i];
					if (l <= 0) {
						int run = 0;
						while (i < w * h && levelsOut[i] <= 0 && run < 256) { run++; i++; }
						data.Add(0); data.Add((byte)(run - 1));
					} else {
						data.Add((byte)l); // Palette index 1 + (l - 1)
						i++;
					}
				}
				frames.Add(data.ToArray());
			}
		}

		int frameEntries = 24, cycles = frameEntries + total * 12, palette = cycles + seqCount * 4;
		int lookup = palette + 1024, dataStart = lookup + total * 2;
		int size = dataStart; foreach (var f in frames) size += f.Length;
		var o = new byte[size];

		Encoding.ASCII.GetBytes("BAM V1  ").CopyTo(o, 0);
		BitConverter.GetBytes((ushort)total).CopyTo(o, 8);
		o[10] = (byte)seqCount;
		o[11] = 0; // RLE color: the transparent index
		BitConverter.GetBytes(frameEntries).CopyTo(o, 12);
		BitConverter.GetBytes(palette).CopyTo(o, 16);
		BitConverter.GetBytes(lookup).CopyTo(o, 20);

		// Palette (BGRA): 0 = transparent green, l = the color at alpha level l, (never alpha 0, which would be opaque)
		o[palette + 1] = 255;
		for (int l = 1; l <= levels; l++) {
			int q = palette + l * 4;
			o[q] = color[2]; o[q + 1] = color[1]; o[q + 2] = color[0];
			o[q + 3] = (byte)Math.Round(l * 255.0 / levels);
		}

		int p = dataStart;
		for (int f = 0; f < total; f++) {
			int e = frameEntries + f * 12;
			BitConverter.GetBytes((ushort)w).CopyTo(o, e);
			BitConverter.GetBytes((ushort)h).CopyTo(o, e + 2);
			BitConverter.GetBytes((uint)p).CopyTo(o, e + 8); // Bit 31 clear: RLE compressed
			frames[f].CopyTo(o, p);
			p += frames[f].Length;
			BitConverter.GetBytes((ushort)f).CopyTo(o, lookup + f * 2);
		}

		for (int s = 0; s < seqCount; s++) {
			BitConverter.GetBytes((ushort)directions).CopyTo(o, cycles + s * 4);
			BitConverter.GetBytes((ushort)(s * directions)).CopyTo(o, cycles + s * 4 + 2);
		}

		File.WriteAllBytes(outPath, o);
		return o.Length;
	}
}
'@

Add-Type -TypeDefinition $source
$out = Join-Path $PSScriptRoot "..\BattleSense\copy\spellinfo\ZJSPLCON.BAM"
$size = [ZJConeBam]::Make([IO.Path]::GetFullPath($out), $widths, $color)
"Wrote $out ($size bytes)"
