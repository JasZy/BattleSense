# Builds the white / grey BAMs that the menus tint, (`useOverlayTint` + `overlayTint`: the BAM's colors are multiplied by
# the tint, so white becomes the tint's color and grey a darker shade of it). A menu has one label per color, each
# with its own fixed tint, and only the label of the chosen color is enabled: the bitmap itself has no copy per color.
#
#   BattleSense/copy/timer/ZJTRRING.BAM          The resistance ring beside a portrait, drawn over the element's icon,
#                                                (core/ZJCREELM.BAM). One sequence of 61 frames, 13x13: frame N has
#                                                N/60 of the ring, clockwise from the top. Frame 60 is the whole ring.
#   BattleSense/copy/creatureinfo/ZJCREDMG.BAM   The shapes of the weapon / spell / item icons of Creature Info, all
#                                                white: the menu tints them a single color. Frame = icon * 2 + facing:
#                                                facing 0 points one way, (the target's attacks), facing 1 the other,
#                                                (attacks on the target).
#   BattleSense/copy/creatureinfo/ZJCREDMH.BAM   Their shading and highlights, (the same frames): grey pixels that are
#                                                partly see-through, drawn on top without a tint.
#
# Both are made from the colored originals in tools/source:
#   ZJTRESIS-colored.BAM: per element, (fire, cold, electricity, acid, magic), the element's icon in a ring that is
#     red, (palette index 1), and green, (index 2), frame N = N/60 green. The icon is the same as core/ZJCREELM.BAM,
#     and the ring is the same for every element except one pixel on its outer edge: the fire one is used.
#   ZJCREDMG-colored.BAM: per icon, (sword, mace, spear, bow, sling, fist, spell, item), 4 frames: green, red, dimmed
#     red, dimmed green. The green ones face the other way. Every pixel is split into some of the option's default
#     color, (Green for the green icons, Red for the red ones), and some white, (the light parts are pale, the
#     highlights white), see Split():
#         pixel = t * color + 255 * white
#     A grey `v` that is `a` opaque drawn over the plain color gives color * (1 - a) + v * a, the same for any color
#     when
#         a = 1 - t,   v = 255 * white / a
#     So the shape is plain white in ZJCREDMG.BAM, (tinted to the color), and v / a go to ZJCREDMH.BAM. With the
#     default colors the icons look like they used to, other colors get the same shading.
#
# The timer bars have no BAM: they are fills, (`fill lua`), in the bar's color.
#
# Run from anywhere: powershell -ExecutionPolicy Bypass -File tools\make-tint-bams.ps1

$source = @'
using System; using System.IO; using System.Text; using System.Collections.Generic;

public class ZJBamReader {
	byte[] o; int nFrames, rle, fe, lut, cycles;
	public int Palette;
	public ZJBamReader(string path) {
		o = File.ReadAllBytes(path);
		if (Encoding.ASCII.GetString(o, 0, 8) != "BAM V1  ") throw new Exception(path + ": not an uncompressed BAM V1");
		nFrames = BitConverter.ToUInt16(o, 8); rle = o[11];
		fe = BitConverter.ToInt32(o, 12); Palette = BitConverter.ToInt32(o, 16); lut = BitConverter.ToInt32(o, 20);
		cycles = fe + nFrames * 12;
	}
	public int FrameOf(int cycle, int index) {
		int start = BitConverter.ToUInt16(o, cycles + cycle * 4 + 2);
		return BitConverter.ToUInt16(o, lut + (start + index) * 2);
	}
	public int Width(int f)  { return BitConverter.ToUInt16(o, fe + f * 12); }
	public int Height(int f) { return BitConverter.ToUInt16(o, fe + f * 12 + 2); }
	public byte[] Pixels(int f) {
		int w = Width(f), h = Height(f);
		uint off = BitConverter.ToUInt32(o, fe + f * 12 + 8);
		bool raw = (off & 0x80000000u) != 0; int p = (int)(off & 0x7FFFFFFFu);
		var px = new byte[w * h]; int i = 0;
		while (i < px.Length) {
			byte b = o[p++];
			if (!raw && b == rle) { int n = o[p++] + 1; for (int k = 0; k < n && i < px.Length; k++) px[i++] = b; }
			else px[i++] = b;
		}
		return px;
	}
	// The RGB of palette entry `index`
	public int[] Rgb(int index) {
		int q = Palette + index * 4;
		return new int[] { o[q + 2], o[q + 1], o[q] };
	}
}

public static class ZJTintBams {

	// Writes a BAM V1 with uncompressed frames: `sequences` lists the frames of each sequence, `palette` the RGB of
	// each index, (index 0 is the transparent green)
	static int Write(string path, List<byte[]> frames, int w, int h, List<int[]> sequences, List<byte[]> palette) {
		int total = frames.Count;
		int frameEntries = 24, cyclesAt = frameEntries + total * 12, paletteAt = cyclesAt + sequences.Count * 4;
		int lookupAt = paletteAt + 1024, lookupCount = 0;
		foreach (var s in sequences) lookupCount += s.Length;
		int dataAt = lookupAt + lookupCount * 2;
		var o = new byte[dataAt + total * w * h];

		Encoding.ASCII.GetBytes("BAM V1  ").CopyTo(o, 0);
		BitConverter.GetBytes((ushort)total).CopyTo(o, 8);
		o[10] = (byte)sequences.Count;
		o[11] = 0; // RLE color, unused: every frame is stored uncompressed
		BitConverter.GetBytes(frameEntries).CopyTo(o, 12);
		BitConverter.GetBytes(paletteAt).CopyTo(o, 16);
		BitConverter.GetBytes(lookupAt).CopyTo(o, 20);

		for (int i = 0; i < palette.Count; i++) {
			int q = paletteAt + i * 4;
			o[q] = palette[i][2]; o[q + 1] = palette[i][1]; o[q + 2] = palette[i][0]; // BGRA
			// Alpha: 1 - 255 how opaque, 0 = opaque, (an entry without a fourth byte is opaque)
			if (palette[i].Length > 3) o[q + 3] = palette[i][3];
		}

		for (int f = 0; f < total; f++) {
			int e = frameEntries + f * 12, p = dataAt + f * w * h;
			BitConverter.GetBytes((ushort)w).CopyTo(o, e);
			BitConverter.GetBytes((ushort)h).CopyTo(o, e + 2);
			BitConverter.GetBytes((uint)p | 0x80000000u).CopyTo(o, e + 8);
			frames[f].CopyTo(o, p);
		}

		int l = 0;
		for (int s = 0; s < sequences.Count; s++) {
			BitConverter.GetBytes((ushort)sequences[s].Length).CopyTo(o, cyclesAt + s * 4);
			BitConverter.GetBytes((ushort)l).CopyTo(o, cyclesAt + s * 4 + 2);
			foreach (int f in sequences[s]) { BitConverter.GetBytes((ushort)f).CopyTo(o, lookupAt + l * 2); l++; }
		}

		File.WriteAllBytes(path, o);
		return o.Length;
	}

	public static int MakeRing(string sourcePath, string outPath) {
		var src = new ZJBamReader(sourcePath);
		var frames = new List<byte[]>();
		var sequence = new int[61];
		for (int i = 0; i <= 60; i++) {
			var px = src.Pixels(src.FrameOf(0, i)); // Fire
			var frame = new byte[px.Length];
			for (int k = 0; k < px.Length; k++) frame[k] = (byte)(px[k] == 2 ? 1 : 0); // The green part, in white
			frames.Add(frame);
			sequence[i] = i;
		}
		var palette = new List<byte[]> { new byte[] { 0, 255, 0 }, new byte[] { 255, 255, 255 } };
		return Write(outPath, frames, 13, 13, new List<int[]> { sequence }, palette);
	}

	// The sword is shaded with 18 greys from 48 up, with a dark smoky glow around its blade, the other icons with 3: an
	// outline, a middle and a light one. Its greys are moved to the nearest of those, and the glow, (below 90), is left
	// out, so it looks like the rest.
	static byte SnapToStyle(byte grey) {
		if (grey < 90) return 0;
		return (byte)(grey < 134 ? 94 : grey < 208 ? 173 : 243);
	}

	// The icons drawn with hard tones, (mace, spear, bow, sling, item), where the others, (sword, fist, spell), are
	// shaded smoothly
	static readonly int[] FlatIcons = { 1, 2, 3, 4, 7 };

	// The icons whose pure white is too bright next to the rest, (the bow's arrow, the item's rope): it becomes a pale
	// shade of the icon's color
	static readonly int[] PaleWhiteIcons = { 3, 7 };

	// The icons whose white is a big block, (the mace's head): softening fades its edges into the color
	static readonly int[] BlendWhiteIcons = { 1 };

	// How much of their white stays white, (the part nearest the light)
	const double PaleWhiteKept = 0.35;

	// The icons without a white highlight, (the fist): their lightest pixels get one, and after softening their very
	// lightest ones a bright spot, see Sparkle()
	static readonly int[] AddWhiteIcons = { 5 };

	// After softening: the very lightest pixels of an AddWhiteIcons icon, nearly white, so they stay crisp spots
	static void Sparkle(int icon, int[][] c) {
		if (Array.IndexOf(AddWhiteIcons, icon) < 0) return;
		var brightness = new List<int>();
		foreach (var p in c) if (p != null) brightness.Add(p[0] + p[1] + p[2]);
		brightness.Sort();
		int threshold = brightness[(int)(brightness.Count * 0.97)];
		foreach (var p in c) {
			if (p == null || p[0] + p[1] + p[2] < threshold) continue;
			for (int ch = 0; ch < 3; ch++) p[ch] = (int)Math.Round(0.15 * p[ch] + 0.85 * 255);
		}
	}

	// Evens out the highlights, see PaleWhiteIcons and AddWhiteIcons. `c` is the frame's colors, (null = transparent).
	// `facing` 0 is the mirror image of 1.
	static void EvenHighlights(int icon, int facing, int[][] c, double[] color) {
		if (Array.IndexOf(PaleWhiteIcons, icon) >= 0) {
			// The part of the white nearest the top left, (where the light comes from, mirrored for facing 0), stays
			// white: a highlight on the arrow head / rope, not the whole of it
			var whites = new List<int>();
			for (int k = 0; k < c.Length; k++) {
				var p = c[k];
				if (p != null && Math.Min(p[0], Math.Min(p[1], p[2])) >= 245) whites.Add(k);
			}
			Func<int, int> towardsLight = k => (facing == 0 ? 31 - k % 32 : k % 32) + k / 32;
			whites.Sort((a, b) => towardsLight(a).CompareTo(towardsLight(b)));
			int keep = (int)Math.Round(whites.Count * PaleWhiteKept);
			for (int i = keep; i < whites.Count; i++) {
				var p = c[whites[i]];
				for (int ch = 0; ch < 3; ch++) p[ch] = (int)Math.Round(0.6 * 255 + 0.4 * color[ch]);
			}
		}
		if (Array.IndexOf(AddWhiteIcons, icon) >= 0) {
			// The lightest tenth of the pixels, a third of the way to white
			var brightness = new List<int>();
			foreach (var p in c) if (p != null) brightness.Add(p[0] + p[1] + p[2]);
			brightness.Sort();
			int threshold = brightness[(int)(brightness.Count * 0.9)];
			foreach (var p in c) {
				if (p == null || p[0] + p[1] + p[2] < threshold) continue;
				for (int ch = 0; ch < 3; ch++) p[ch] = (int)Math.Round(0.67 * p[ch] + 0.33 * 255);
			}
		}
	}

	// Softens a flat icon so it matches the smooth ones: every pixel is mixed with its neighbours, (only the icon's own
	// pixels, so the outline keeps its place), which puts in-between shades where two tones meet. Pure white
	// highlights keep their white, their neighbours get some of it, unless `blendWhite`: then the white fades into the
	// color at its edges too, (its middle stays white). `rgb` is the frame's colors, (null = transparent).
	static int[][] Soften(int[][] rgb, bool blendWhite) {
		var soft = new int[rgb.Length][];
		for (int y = 0; y < 32; y++) for (int x = 0; x < 32; x++) {
			int k = y * 32 + x;
			if (rgb[k] == null) continue;
			if (!blendWhite && Math.Min(rgb[k][0], Math.Min(rgb[k][1], rgb[k][2])) >= 245) { soft[k] = rgb[k]; continue; }
			// The pixel itself counts most, so thin lines, (the bow), keep their strength
			double[] sum = { rgb[k][0] * 8.0, rgb[k][1] * 8.0, rgb[k][2] * 8.0 };
			double weight = 8;
			for (int dy = -1; dy <= 1; dy++) for (int dx = -1; dx <= 1; dx++) {
				if (dx == 0 && dy == 0) continue;
				int nx = x + dx, ny = y + dy;
				if (nx < 0 || ny < 0 || nx >= 32 || ny >= 32) continue;
				var n = rgb[ny * 32 + nx];
				if (n == null) continue;
				double w = (dx == 0 || dy == 0) ? 1 : 0.5; // Diagonals count half
				for (int ch = 0; ch < 3; ch++) sum[ch] += n[ch] * w;
				weight += w;
			}
			soft[k] = new int[] { (int)Math.Round(sum[0] / weight), (int)Math.Round(sum[1] / weight), (int)Math.Round(sum[2] / weight) };
		}
		return soft;
	}

	// The default colors of Creature Info's icon options, (ZJBarColors_Colors in ZJBarCol.lua): Green for the target's
	// attacks, (facing 0, the old green icons), Red for attacks on the target, (facing 1, the old red ones)
	static readonly double[] TargetAttackColor = { 0, 210, 0 };
	static readonly double[] AttackColor = { 230, 0, 0 };

	// Splits the old pixel `c` into `t` of `color` plus `white` of white: c = t * color + 255 * white, as close as it can
	// get, (least squares over the 3 channels), with 0 <= white and 0 <= t <= 1 - white. With the default color the
	// icon then looks like it used to, highlights and all, and other colors get the same shading.
	static void Split(int[] c, double[] color, out double t, out double white) {
		double sCC = 0, sC = 0, sCc = 0, sc = 0;
		for (int i = 0; i < 3; i++) { sCC += color[i] * color[i]; sC += color[i]; sCc += color[i] * c[i]; sc += c[i]; }
		// The normal equations of the least squares, with u = 255 * white:
		//   t * sCC + u * sC = sCc
		//   t * sC  + u * 3  = sc
		double det = sCC * 3 - sC * sC;
		t = (sCc * 3 - sC * sc) / det;
		double u = (sCC * sc - sC * sCc) / det;
		white = u / 255;
		// Out of bounds: keep the one that is, and fit the other again
		for (int pass = 0; pass < 2; pass++) {
			if (white < 0) white = 0;
			if (white > 1) white = 1;
			if (t < 0 || t > 1 - white) {
				t = Math.Max(0, Math.Min(1 - white, (sCc - 255 * white * sC) / sCC));
				white = Math.Max(0, Math.Min(1 - t, (sc - t * sC) / (3 * 255)));
			}
		}
	}

	// Removes the pixels of a 32x32 shape that have no neighbour, (left over from the sword's glow), from the shape and
	// its overlay
	static void RemoveLonePixels(byte[] shape, int[] overlay) {
		var lone = new List<int>();
		for (int y = 0; y < 32; y++) for (int x = 0; x < 32; x++) {
			int k = y * 32 + x;
			if (shape[k] == 0) continue;
			bool neighbour = false;
			foreach (int[] d in new int[][] { new[] { -1, 0 }, new[] { 1, 0 }, new[] { 0, -1 }, new[] { 0, 1 } }) {
				int nx = x + d[0], ny = y + d[1];
				if (nx < 0 || ny < 0 || nx >= 32 || ny >= 32) continue;
				if (shape[ny * 32 + nx] != 0) neighbour = true;
			}
			if (!neighbour) lone.Add(k);
		}
		foreach (int k in lone) { shape[k] = 0; overlay[k] = -1; }
	}

	// Writes the icons' shapes, (plain white, tinted by the menu), to `outPath`, and their shading and highlights, (see
	// the top of this file), to `overlayPath`. Same frames in both.
	public static string MakeDamageIcons(string sourcePath, string outPath, string overlayPath) {
		var src = new ZJBamReader(sourcePath);
		var shapes = new List<byte[]>();
		var overlays = new List<int[]>(); // Per pixel: grey * 256 + alpha, (alpha 1 - 255), or -1 for none
		var sequence = new int[16];
		for (int icon = 0; icon < 8; icon++) {
			for (int facing = 0; facing < 2; facing++) {
				// Facing 0 is the old green frame, facing 1 the old red one
				var px = src.Pixels(icon * 4 + facing);
				var defaultColor = facing == 0 ? TargetAttackColor : AttackColor;
				var colors = new int[px.Length][];
				for (int k = 0; k < px.Length; k++) colors[k] = px[k] == 0 ? null : src.Rgb(px[k]);
				// The highlights first, so softening blends them in, (the fist's new ones would be speckles otherwise)
				EvenHighlights(icon, facing, colors, defaultColor);
				if (Array.IndexOf(FlatIcons, icon) >= 0 || Array.IndexOf(AddWhiteIcons, icon) >= 0) {
					colors = Soften(colors, Array.IndexOf(BlendWhiteIcons, icon) >= 0);
				}
				Sparkle(icon, colors);
				var shape = new byte[px.Length];
				var overlay = new int[px.Length];
				for (int k = 0; k < px.Length; k++) {
					overlay[k] = -1;
					if (px[k] == 0) continue;
					// The pixel, split into the option's default color and white, see Split()
					int[] c = colors[k];
					if (icon == 0) {
						int max = Math.Max(c[0], Math.Max(c[1], c[2]));
						int snapped = SnapToStyle((byte)max);
						if (snapped == 0) continue; // The sword's glow
						for (int ch = 0; ch < 3; ch++) c[ch] = (int)Math.Round(c[ch] * (double)snapped / max);
					}
					double t, white;
					Split(c, defaultColor, out t, out white);
					shape[k] = 1;
					double a = 1 - t;
					int alpha = (int)Math.Round(a * 255);
					if (alpha < 1) continue; // The plain color: nothing on top
					int v = (int)Math.Min(255, Math.Round(255 * white / a));
					overlay[k] = v * 256 + alpha;
				}
				if (icon == 0) RemoveLonePixels(shape, overlay);
				sequence[shapes.Count] = shapes.Count;
				shapes.Add(shape);
				overlays.Add(overlay);
			}
		}

		// The overlay's palette, (index 0 is the transparent green): the 255 grey / alpha pairs used most. A pair that
		// doesn't fit uses the one that looks closest, (what it adds over the color: v * a, and how much of the color it
		// hides: a).
		var counts = new Dictionary<int, int>();
		foreach (var overlay in overlays) foreach (int o in overlay) {
			if (o < 0) continue;
			int n; counts.TryGetValue(o, out n); counts[o] = n + 1;
		}
		var used = new List<int>(counts.Keys);
		used.Sort((x, y) => counts[y].CompareTo(counts[x]));
		var kept = used.GetRange(0, Math.Min(255, used.Count));
		var overlayPalette = new List<byte[]> { new byte[] { 0, 255, 0 } };
		var indexOf = new Dictionary<int, int>();
		foreach (int key in kept) {
			indexOf[key] = overlayPalette.Count;
			byte grey = (byte)(key >> 8);
			overlayPalette.Add(new byte[] { grey, grey, grey, (byte)(key & 255) });
		}
		foreach (int key in used) {
			if (indexOf.ContainsKey(key)) continue;
			double kv = key >> 8, ka = key & 255, best = double.MaxValue; int bestIndex = 1;
			foreach (int other in kept) {
				double ov = other >> 8, oa = other & 255;
				double added = (kv * ka - ov * oa) / 255, hidden = ka - oa;
				double d = added * added + hidden * hidden;
				if (d < best) { best = d; bestIndex = indexOf[other]; }
			}
			indexOf[key] = bestIndex;
		}
		var overlayFrames = new List<byte[]>();
		foreach (var overlay in overlays) {
			var frame = new byte[overlay.Length];
			for (int k = 0; k < overlay.Length; k++) {
				if (overlay[k] < 0) continue;
				frame[k] = (byte)indexOf[overlay[k]];
			}
			overlayFrames.Add(frame);
		}
		int merged = used.Count - kept.Count;

		var shapePalette = new List<byte[]> { new byte[] { 0, 255, 0 }, new byte[] { 255, 255, 255 } };
		int size = Write(outPath, shapes, 32, 32, new List<int[]> { sequence }, shapePalette);
		int overlaySize = Write(overlayPath, overlayFrames, 32, 32, new List<int[]> { sequence }, overlayPalette);
		return size + " / " + overlaySize + " bytes, overlay colors: " + used.Count + ", " + merged + " of them merged into the closest of the 255 used most";
	}
}
'@

Add-Type -TypeDefinition $source
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))

$out = Join-Path $root "BattleSense\copy\timer\ZJTRRING.BAM"
$size = [ZJTintBams]::MakeRing((Join-Path $root "tools\source\ZJTRESIS-colored.BAM"), $out)
"Wrote $out ($size bytes)"

$out = Join-Path $root "BattleSense\copy\creatureinfo\ZJCREDMG.BAM"
$overlayOut = Join-Path $root "BattleSense\copy\creatureinfo\ZJCREDMH.BAM"
$sizes = [ZJTintBams]::MakeDamageIcons((Join-Path $root "tools\source\ZJCREDMG-colored.BAM"), $out, $overlayOut)
"Wrote $out and $overlayOut ($sizes)"
