module decouple_adapter (
  decople_if.in in,
  decople_if.out out
);
  assign in.valid = out.valid;
  assign out.ready = in.ready;
endmodule
