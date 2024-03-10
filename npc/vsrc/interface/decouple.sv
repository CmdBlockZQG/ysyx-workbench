interface decouple_if;
  logic valid;
  logic ready;

  modport in (
    input valid,
    output ready
  );

  modport out (
    output valid,
    input ready
  );
endinterface
