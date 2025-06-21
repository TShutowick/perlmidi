# PerlMIDI

A real-time MIDI sequencer and device interface written in Perl.

This project allows you to define MIDI note sequences in YAML and send MIDI messages directly to a hardware or software MIDI device.

---

## YAML Pattern Format
- Each sequence can contain notes, rests, or references to defined patterns.
- Notes can be defined as single values or arrays for polyphony.
- The `speed` multiplier adjusts how quickly notes are played.
- The `channel` specifies the MIDI channel (0-based indexing).
- The `program` can be set to change the instrument sound.
    - Program numbers will depend on your MIDI device

---

## Example: YAML Drum Pattern

```yaml
channel: 9 # standard MIDI channel for drums - perlmidi uses 0-based indexing
speed: 1 # Speed multiplier for note playback - higher values play notes faster
definitions:
  kick:  35 # low bass drum under General MIDI
  snare: 38 # standard snare drum under General MIDI
sequences:
  intro:
    - 128x_ # Silence for 128 ticks
  verse:
    - 2x$kick # Two kicks in a row
    - $snare
    - $kick
structure:
  - intro
  - verse
```

---

## Example: Polyphonic Chord Progression

```yaml
# chords for Cocteau Twins' "Cherry-Coloured Funk"
channel: 0
speed: 1
program: 3 # General MIDI program number for electric piano
definitions:
  a_maj_7: [55, 61, 64] # A major 7 chord
  e_maj:   [64, 68, 71] # E major chord
  d_maj:   [62, 66, 69] # D major chord
  fs_min:  [57, 61, 66] # F# minor chord
  cs_min:  [61, 64, 68] # C# minor chord
  b_min:   [59, 62, 66] # B minor chord
sequences:
  verse:
    - 8x$a_maj_7 # Play A major 7 chord 8 times
    - 8x$e_maj   # Play E major chord 8 times
    - 16x$d_maj  # Play D major chord 16 times
  chorus:
    - 8x$fs_min # Play F# minor chord 8 times
    - 8x$cs_min # Play C# minor chord 8 times
    - 16x$b_min # Play B minor chord 16 times
structure:
  - verse
  - verse
  - chorus
  - chorus
```

---

## Usage

```perl
use PerlMIDI::Parser;
use PerlMIDI::Device;
use PerlMIDI::Sequencer;

my $device = PerlMIDI::Device->new(path => '/dev/midi1');

my $track = PerlMIDI::Parser::load_file(path => 'pattern.yaml');

my $sequencer = PerlMIDI::Sequencer->new(
    bpm    => 120,
    tracks => [$track],
    device => $device,
);

while (1) {
    $sequencer->play();
}
```

---

## Project Structure

- `PerlMIDI::Device` – MIDI device I/O
- `PerlMIDI::Sequencer` – Manages playback timing
- `PerlMIDI::Sequence` – Handles note sequencing and polyphony
- `PerlMIDI::Parser` – Loads YAML patterns and converts them to sequences
- `PerlMIDI::Utils` – Builds MIDI byte arrays
