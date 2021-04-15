// Copyright (c) 2014, <Jaron Tai>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library progress_bar.base;

import 'dart:io';
import 'dart:math';

/// ProgressBar
class ProgressBar {
  late String format;
  late int total;
  late int width;
  bool clear = false;
  late String completeChar;
  late String incompleteChar;
  int curr = 0;
  late DateTime start;
  late String lastDraw;
  bool complete = false;
  //late Function callback;

  /// Initialize a `ProgressBar` with the given `format` string and the `options` map.
  ///
  /// Format tokens:
  ///
  ///   - `:bar` the progress bar itself
  ///   - `:current` current tick number
  ///   - `:total` total ticks
  ///   - `:elapsed` time elapsed in seconds
  ///   - `:percent` completion percentage
  ///   - `:eta` eta in seconds
  ///
  /// Options:
  ///
  ///   - `total` total number of ticks to complete
  ///   - `width` the displayed width of the progress bar defaulting to total
  ///   - `complete` completion character defaulting to "="
  ///   - `incomplete` incomplete character defaulting to "-"
  ///   - `callback` optional function to call when the progress bar completes
  ///   - `clear` will clear the progress bar upon termination
  ///
  ProgressBar(
    String format, {
    int total: 0,
    int width: 100,
    bool clear: false,
    String complete: '=',
    String incomplete: '-',
    //   Function callback
  }) {
    this.format = format;
    this.total = total;
    if (width == null) {
      this.width = this.total;
    } else {
      this.width = width;
    }
    this.clear = clear;
    this.completeChar = complete;
    this.incompleteChar = incomplete;
    //this.callback = callback;
  }

  /// "tick" the progress bar with optional `len` and optional `tokens`.
  tick({int len: 1, required Map<String, String> tokens}) {
    if (this.curr == 0) {
      this.start = new DateTime.now();
    }

    this.curr += len;
    this.render(tokens);

    // progress complete
    if (this.curr >= this.total) {
      this.complete = true;
      this.terminate();
      // if (this.callback is Function) {
      //   Function.apply(this.callback, [this.complete]);
      // }
    }
  }

  /// Method to render the progress bar with optional `tokens` to place in the
  /// progress bar's `format` field.
  ///
  render(Map<String, String> tokens) {
    if (!stdout.hasTerminal) return;

    var ratio = this.curr / this.total;
    ratio = min(max(ratio, 0.0), 1.0);

    var percent = ratio * 100;
    var elapsed = new DateTime.now().difference(this.start).inMilliseconds;
    var eta = (percent == 100) ? 0 : elapsed * (this.total / this.curr - 1);

    /* populate the bar template with percentages and timestamps */
    var str = this
        .format
        .replaceAll(':current', this.curr.toString())
        .replaceAll(':total', this.total.toString())
        .replaceAll(':elapsed', elapsed.isNaN ? '0.0' : (elapsed / 1000).toStringAsFixed(1))
        .replaceAll(':eta', (eta.isNaN || !eta.isFinite) ? '0.0' : (eta / 1000).toStringAsFixed(1))
        .replaceAll(':percent', percent.toStringAsFixed(0) + '%');

    /* compute the available space (non-zero) for the bar */
    var availableSpace = max(0, stdout.terminalColumns - str.replaceAll(':bar', '').length);
    var width = min(this.width, availableSpace);

    /* the following assumes the user has one ':bar' token */
    var incomplete, complete;
    int completeLength;
    completeLength = (width * ratio).round();
    complete = new List<String>.filled(completeLength, this.completeChar).join();
    incomplete = new List<String>.filled(width - completeLength, this.incompleteChar).join();

    /* fill in the actual progress bar */
    str = str.replaceAll(':bar', complete + incomplete);

    /* replace the extra tokens */
    tokens.forEach((key, val) {
      str = str.replaceAll(':' + key, val);
    });

    if (this.lastDraw != str) {
      stdout.writeCharCode(13); // output carriage return
      stdout.write(str);
      this.lastDraw = str;
    }
  }

  /// "update" the progress bar to represent an exact percentage.
  /// The ratio (between 0 and 1) specified will be multiplied by `total` and
  /// floored, representing the closest available "tick." For example, if a
  /// progress bar has a length of 3 and `update(0.5)` is called, the progress
  /// will be set to 1.
  ///
  /// A ratio of 0.5 will attempt to set the progress to halfway.
  ///
  update(num ratio) {
    var goal = (ratio * this.total).floor();
    var delta = goal - this.curr;
    this.tick(len: delta, tokens: {});
  }

  /// Terminates a progress bar.
  ///
  terminate() {
    if (this.clear) {
      for (int i = 0; i < stdout.terminalColumns; i++) {
        stdout.writeCharCode(8); // output backspace
      }
    } else {
      stdout.writeln();
    }
  }
}
