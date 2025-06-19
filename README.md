# PerlMIDI

A real-time MIDI sequencer and device interface written in Perl.

This project allows you to define MIDI note sequences in YAML and send MIDI messages directly to a hardware or software MIDI device.

---

## Example: YAML Drum Pattern

```yaml
channel: 1
speed: 1
definitions:
  kick: 60
  snare: 64
sequences:
  verse:
    - $kick
    - $kick
    - $snare
    - $kick
structure:
  - verse
```

---

## Example: Polyphonic Chord Progression

```yaml
channel: 0
speed: 1
definitions:
  a_maj_7: [55, 61, 64]
  e_maj:   [64, 68, 71]
  d_maj:   [62, 66, 69]
  fs_min:  [57, 61, 66]
  cs_min:  [61, 64, 68]
  b_min:   [59, 62, 66]
sequences:
  verse:
    - 8x$a_maj_7
    - 8x$e_maj
    - 16x$d_maj
  chorus:
    - 8x$fs_min
    - 8x$cs_min
    - 16x$b_min
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
