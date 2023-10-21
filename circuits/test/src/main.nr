fn main(x : Field, y : pub Field) {
    let z = 1000.pow_32(10944121435919637611123202872628637544274182200208017171849102093287904247808);
    assert(z != 1);
}

#[test]
fn test_main() {
    main(1, 2);

    // Uncomment to make test fail
    // main(1, 1);
}
