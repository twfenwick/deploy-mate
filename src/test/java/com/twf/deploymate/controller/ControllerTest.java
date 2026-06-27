package com.twf.deploymate.controller;

import org.junit.jupiter.api.Test;

class ControllerTest {
    Controller controller = new Controller();

    @Test
    void bunnyIsDrawn() {
        assert("(\\(\\ <br>(-.-) <br>o_(\")(\")".equals(controller.apiRoot()));
    }
}
